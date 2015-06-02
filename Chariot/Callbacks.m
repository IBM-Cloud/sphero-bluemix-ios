/*
 * Copyright IBM Corp. 2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors:
 *    Mike Robertson - initial contribution
 */

//
//  Callbacks.m
//  IoTstarter
//

#import "Callbacks.h"
#import "IoTStarterViewController.h"

@implementation InvocationCallbacks

/** Is called when the function the protocol is assigned to completes successfully
 *  @param invocationContext A pointer to a variable or object that is to be made
 *  available to the onSuccess function, for example the MqttClient object
 */
- (void)onSuccess:(NSObject *)invocationContext
{
    //NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
    if ([invocationContext isKindOfClass:[MqttClient class]])
    {
        // context is Mqtt Publish
    }
    else if ([invocationContext isKindOfClass:[NSString class]])
    {
        NSString *contextString = (NSString *)invocationContext;
        if ([contextString isEqualToString:@"connect"])
        {
            [self handleConnectSuccess];
        }
        else if ([contextString isEqualToString:@"disconnect"])
        {
            [self handleDisconnectSuccess];
        }
        else
        {
            NSArray *parts = [contextString componentsSeparatedByString:@":"];
            if ([parts[0] isEqualToString:@"subscribe"])
            {
                // Context is Mqtt Subscribe
                NSLog(@"Successfully subscribed to topic: %@", parts[1]);
            }
            else if ([parts[0] isEqualToString:@"unsubscribe"])
            {
                // Context is Mqtt Unsubscribe
                NSLog(@"Successfully unsubscribed from topic: %@", parts[1]);
            }
        }
    }
}

/** Is called when the function the protocol is assigned to fails to complete
 *  successfully
 *  @param invocationContext A pointer to a variable or object that is to be made
 *  available to the onSuccess function, for example the MqttClient object
 *  @param errorCode An error code indicating the reason for the failure (this may
 *  not always be available)
 *  @param errorMessage An error message indicating the reason for the failure (this
 *  may not always be available)
 */
- (void)onFailure:(NSObject *)invocationContext
        errorCode:(int)errorCode
     errorMessage:(NSString *)errorMessage
{
    //NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__, __LINE__, invocationContext, errorCode, errorMessage);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate updateViewLabelsAndButtons];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"Failed to connect to IoT. Reason Code: %d", errorCode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connect Failed" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:OK_STRING, nil];
        [alert show];
    });
}

/** Called upon successful connection to the server. Start the iOS motion manager and
 *  update the views to indicate that the application is now connected. Subscribe to
 *  the wildcard command topic for this device.
 */
- (void)handleConnectSuccess
{
    // context is Mqtt Connect
    // Enable publishing of sensor data
    NSLog(@"Successfully connected to IoT Messaging Server");
    dispatch_async(dispatch_get_main_queue(), ^{
        // Launch timer for publishing accelerometer data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isConnected = YES;
        [appDelegate updateViewLabelsAndButtons];
        if (appDelegate.isAccelEnabled)
        {
            [appDelegate startMotionManager];
        }
        
        if (!(appDelegate.connectionType == QUICKSTART))
        {
            Messenger *messenger = [Messenger sharedMessenger];
            if (appDelegate.connectionType == M2M) {
                [messenger subscribe:[TopicFactory getM2MCommandTopic:@"+"] qos:0];
            } else {
                [messenger subscribe:[TopicFactory getCommandTopic:@"+"] qos:0];
            }
        }
        [appDelegate setupRobotConnection];
        [appDelegate switchToRemoteView];
        [appDelegate startMotionManager];
    });
}

/** Called upon successful disconnect from the server. Stop the iOS motion manager
 *  and update views to indicate that the application is no longer connected.
 */
- (void)handleDisconnectSuccess
{
    // Context is Mqtt Disconnect
    // Disable publishing of sensor data
    NSLog(@"Successfully disconnected from IoT Messaging Server");
    dispatch_async(dispatch_get_main_queue(), ^{
        // Kill the timer to stop publishing accelerometer data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isConnected = NO;
        [appDelegate updateViewLabelsAndButtons];
        if (appDelegate.isAccelEnabled)
        {
            [appDelegate stopMotionManager];
        }
        // End background task
        //[[UIApplication sharedApplication] endBackgroundTask:appDelegate.bgTask];
    });
}

@end

@implementation GeneralCallbacks

/** Called when the MQTT Client detects that the connection to the server was lost.
 *  @param invocationContext An NSString object with contents "connect"
 *  @param errorMessage The message indicating what failure occurred
 */
- (void)onConnectionLost:(NSObject *)invocationContext
            errorMessage:(NSString *)errorMessage
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    dispatch_async(dispatch_get_main_queue(), ^{
        // Kill the timer to stop publishing accelerometer data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isConnected = NO;
        [appDelegate updateViewLabelsAndButtons];
        [appDelegate stopMotionManager];
    });
}

/** Called when an MQTT message arrives at the client.
 *  @param invocationContext A pointer to a variable or object that is to be made
 *   available to the onSuccess function, for example the MqttClient object
 *  @param message The message that was received.
 */
- (void)onMessageArrived:(NSObject *)invocationContext
                 message:(MqttMessage *)message
{
    //NSLog(@"%s:%d entered", __func__, __LINE__);
    NSString *payload = [[NSString alloc] initWithBytes:message.payload length:message.payloadLength encoding:NSASCIIStringEncoding];
    NSString *topic = message.destinationName;
    
    [self routeMessage:topic payload:payload];
    
    // Local Notifications when a message is received while app is running in background.
    /*NSLog(@"%ld", [[UIApplication sharedApplication] applicationState]);
    NSLog(@"active %ld background %ld inactive %ld", UIApplicationStateActive, UIApplicationStateBackground, UIApplicationStateInactive);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate.appState != UIApplicationStateActive)
        {
            NSLog(@"Scheduling notification");
            UILocalNotification *alarm = [[UILocalNotification alloc] init];
            alarm.alertBody = @"this is a test";
            alarm.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            alarm.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:alarm];
        }
    });*/
}

/** If the client publishes a message to an MQTT topic,
 *  this method is executed upon successful delivery of that message to
 *  the MQTT server.
 *  @param invocationContext A pointer to a variable or object that is to be made
 *  available to the onMessageDelivered function, for example the MqttClient object
 *  @param msgId the message identifier of the delivered message (no value
 *  if the delivered message was QoS0)
 */
- (void)onMessageDelivered:(NSObject *)invocationContext
                 messageId:(int)msgId
{
}

/** Parse the message topic and call the appropriate method based on the command type.
 *  @param topic The topic string the message was received on
 *  @param payload The message payload
 */
- (void)routeMessage:(NSString *)topic payload:(NSString *)payload
{
    // topicParts: @"iot-2/cmd/%@/fmt/%@"
    //   [0] = iot-2
    //   [1] = cmd
    //   [2] = <command>
    //   [3] = fmt
    //   [4] = <format>
    NSArray *topicParts = [topic componentsSeparatedByString:@"/"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.receiveCount++;
        [appDelegate.iotViewController updateMessageCounts];
        //NSLog(@"%@ : %@", topic, payload);
        if ([topicParts[2] isEqualToString:IOTColorEvent] || [topicParts[3] isEqualToString:IOTColorEvent])
        {
            [self processColorMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTTextEvent] || [topicParts[3] isEqualToString:IOTTextEvent])
        {
            [self processTextMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTTakePictureEvent] || [topicParts[3] isEqualToString:IOTTakePictureEvent])
        {
            [self processTakePictureMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTSpheroColorEvent] || [topicParts[3] isEqualToString:IOTSpheroColorEvent])
        {
            [self processSpheroColorMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTSpheroOriginEvent] || [topicParts[3] isEqualToString:IOTSpheroOriginEvent])
        {
            [self processSpheroOriginMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTSpheroRollEvent] || [topicParts[3] isEqualToString:IOTSpheroRollEvent])
        {
            [self processSpheroRollMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTSpheroRotateEvent] || [topicParts[3] isEqualToString:IOTSpheroRotateEvent])
        {
            [self processSpheroRotateMessage:payload];
        }
        else if ([topicParts[2] isEqualToString:IOTLightEvent] || [topicParts[3] isEqualToString:IOTLightEvent])
        {
            [appDelegate toggleLight];
        }
        else if ([topicParts[2] isEqualToString:IOTAlertEvent] || [topicParts[3] isEqualToString:IOTAlertEvent])
        {
            [self processAlertMessage:payload];
        }
    });
}

/** Return the contents of the "d" JSON object from the message payload.
 *  @param payload The message payload
 *  @return An NSDictionary object containing the JSON contents of the "d" JSON object.
 */
- (NSDictionary *)getMessageBody:(NSString *)payload
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]
                          options:NSJSONReadingMutableContainers
                          error:&error];
    
    if (!json)
    {
        NSLog(@"Error parsing JSON: %@", error);
        return nil;
    }
    
    NSDictionary *body = [json objectForKey:@"d"];
    if (body == nil)
    {
        NSLog(@"Error in JSON: \"d\" object not found");
        return nil;
    }
    return body;
}

/** Process a color command message.
 *  @param payload The message payload
 */
- (void)processColorMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *body;
    body = [self getMessageBody:payload];
    if (body == nil)
    {
        return;
    }
    
    NSNumber *rValue = [body objectForKey:@"r"];
    NSNumber *gValue = [body objectForKey:@"g"];
    NSNumber *bValue = [body objectForKey:@"b"];
    NSNumber *alphaValue = [body objectForKey:@"alpha"];
    if (!rValue || !gValue || !bValue || !alphaValue)
    {
        NSLog(@"Error in JSON: One of \"r\", \"g\", \"b\" or \"alpha\" not found");
        return;
    }
    double r = [rValue doubleValue];
    double g = [gValue doubleValue];
    double b = [bValue doubleValue];
    double a = [alphaValue doubleValue];
    if ((r < 0 || r > 255) ||
        (g < 0 || g > 255) ||
        (b < 0 || b > 255) ||
        (a < 0 || a > 1))
    {
        NSLog(@"Invalid ARGB values");
        return;
    }
    
    //NSLog(@"r: %@, g: %@, b: %@, alpha: %@", rValue, gValue, bValue, alphaValue);
    UIColor *color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
    [appDelegate updateColor:color];
}

/** Process a text command message.
 *  @param payload The message payload
 */
- (void)processTextMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *body;
    body = [self getMessageBody:payload];
    if (body == nil)
    {
        return;
    }
    
    NSString *textValue = [body objectForKey:@"text"];
    if (textValue)
    {
        [appDelegate addLogMessage:textValue];
    }
}

- (void)processSpheroColorMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *body;
    body = [self getMessageBody:payload];
    if (body == nil)
    {
        return;
    }
    
    NSNumber *rValue = [body objectForKey:@"r"];
    NSNumber *gValue = [body objectForKey:@"g"];
    NSNumber *bValue = [body objectForKey:@"b"];
    if (!rValue || !gValue || !bValue || [rValue isKindOfClass:[NSNull class]] || [gValue isKindOfClass:[NSNull class]] || [bValue isKindOfClass:[NSNull class]])
    {
        NSLog(@"Error in JSON: One of \"r\", \"g\" or \"b\" not found");
        return;
    }
    double r = [rValue doubleValue];
    double g = [gValue doubleValue];
    double b = [bValue doubleValue];
    if ((r < 0 || r > 255) ||
        (g < 0 || g > 255) ||
        (b < 0 || b > 255))
    {
        NSLog(@"Invalid RGB values");
        return;
    }
    
    NSLog(@"r: %@, g: %@, b: %@", rValue, gValue, bValue);
    [appDelegate updateSpheroColorWithRed:r/255.0 green:g/255.0 blue:b/255.0];
}

- (void)processSpheroRollMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *body;
    body = [self getMessageBody:payload];
    if (body == nil)
    {
        return;
    }
    
    NSNumber *velocityValue = [body objectForKey:@"velocity"];
    NSNumber *headingValue = [body objectForKey:@"heading"];
    if (!velocityValue || !headingValue)
    {
        NSLog(@"Error in JSON: One of \"velocity\" or \"heading\" not found");
        return;
    }
    double velocity = [velocityValue doubleValue];
    double heading = [headingValue doubleValue];
    if ((velocity < 0 || velocity > 1) ||
        (heading < 0 || heading > 360))
    {
        NSLog(@"Invalid heading/velocity values");
        return;
    }
    
    NSLog(@"heading: %@, velocity: %@", headingValue, velocityValue);
    [appDelegate updateSpheroRollWithHeading:heading velocity:velocity];
}

- (void)processSpheroRotateMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *body;
    body = [self getMessageBody:payload];
    if (body == nil)
    {
        return;
    }
    
    NSNumber *rotationValue = [body objectForKey:@"degrees"];
    NSNumber *timeValue = [body objectForKey:@"seconds"];
    if (!timeValue)
    {
        timeValue = [NSNumber numberWithInt:1];
    }
    double degrees = [rotationValue doubleValue];
    double seconds = [timeValue doubleValue];
    if ((degrees < 0 || degrees > 65356) ||
        (seconds < 0 || seconds > 1000))
    {
        NSLog(@"Invalid degrees/seconds values");
        return;
    }
    
    [appDelegate rotateSpheroWithRotation:degrees time:seconds];
}

- (void)processSpheroOriginMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate resetSpheroOrigin];
}

/** Process a take picture command message.
 *  @param payload The message payload
 */
- (void)processTakePictureMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate takePicture];
}

/** Process an alert command message.
 *  @param payload The message payload
 */
- (void)processAlertMessage:(NSString *)payload
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDictionary *body;
    body = [self getMessageBody:payload];
    if (body == nil)
    {
        return;
    }
    
    NSString *textValue = [body objectForKey:@"text"];
    if (textValue)
    {
        [appDelegate addLogMessage:textValue];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Received Alert" message:textValue delegate:self cancelButtonTitle:nil otherButtonTitles:OK_STRING, nil];
        [alert show];
    }
}

@end
