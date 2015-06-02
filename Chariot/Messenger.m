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
//  Messenger.m
//  IoTstarter
//

#import "Messenger.h"

@implementation Messenger

- (id)init
{
    if (self = [super init])
    {
        self.client = [MqttClient alloc];
        self.client.callbacks = [[GeneralCallbacks alloc] init];
        self.tracer = [[Trace alloc] initWithTraceLevel:2];
    }
    return self;
}

/** Return the singleton instance of the Messenger object.
 */
+ (id)sharedMessenger
{
    static Messenger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

#pragma mark Instance Methods

/** Return true if the client is currently connected.
 *  Return false otherwise.
 */
- (BOOL)isMqttConnected
{
    BOOL connected = NO;
    if (self.client != nil && self.client.isConnected)
    {
        connected = YES;
    }
    return connected;
}

/** Create the connection to the MQTT server.
 *  @param host The host of the server to connect to.
 *  @param port The port of the server to connect to.
 *  @param clientId The MQTT client ID to connect with.
 */
- (void)connectWithHost:(NSString *)host
                   port:(int)port
               clientId:(NSString *)clientId
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if (![self isMqttConnected])
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        ConnectOptions *opts = [[ConnectOptions alloc] init];
        opts.timeout = 5;
        opts.cleanSession = YES;
        opts.keepAliveInterval = 30;
        if (appDelegate.connectionType == IOTF)
        {
            opts.userName = @"use-token-auth";
            opts.password = [appDelegate authToken];
        }
        
        [MqttClient setTrace:self.tracer];
        
        NSLog(@"Connecting to IoT Messaging Server\n\thost: %@\n\tport: %d\n\tclientid: %@\n\tusername: %@\n\tpassword: ********", host, port, clientId, opts.userName);
        self.client = [self.client initWithHost:host port:port clientId:clientId];
        
        [self.client connectWithOptions:opts invocationContext:@"connect" onCompletion:[[InvocationCallbacks alloc] init]];
    }
}

/** Publish a message to the MQTT server.
 *  @param topic The topic to publish the message to
 *  @param payload The content of the message
 *  @param qos The quality of service to send the message at
 *  @param retained Whether this is a retained message
 */
- (void)publish:(NSString *)topic
        payload:(NSString *)payload
            qos:(int)qos
       retained:(BOOL)retained
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if ([self isMqttConnected])
    {
        char *utfPayload = (char *)[payload UTF8String];
        
        MqttMessage *msg = [[MqttMessage alloc] initWithMqttMessage:topic payload:utfPayload length:(int)payload.length qos:qos retained:retained duplicate:NO];
        
        [self.client send:msg invocationContext:@"publish" onCompletion:[[InvocationCallbacks alloc] init]];
    }
}

/** Subscribe to topic filter topicFilter at quality of service qos.
 *  @param topicFilter The MQTT topic filter to subscribe to
 *  @param qos The quality of service to subscribe with.
 */
- (void)subscribe:(NSString *)topicFilter
              qos:(int)qos
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if ([self isMqttConnected])
    {
        NSString *context = [@"subscribe:" stringByAppendingString:topicFilter];
        [self.client subscribe:topicFilter qos:qos invocationContext:context onCompletion:[[InvocationCallbacks alloc] init]];
    }
}

/** Unsubscribe from topic filter topicFilter.
 *  @param topicFilter The MQTT topic filter to unsubscribe from
 */
- (void)unsubscribe:(NSString *)topicFilter
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if ([self isMqttConnected])
    {
        NSString *context = [@"unsubscribe:" stringByAppendingString:topicFilter];
        [self.client unsubscribe:topicFilter invocationContext:context onCompletion:[[InvocationCallbacks alloc] init]];
    }
}

/** Disconnect from the MQTT server.
 */
- (void)disconnect
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if ([self isMqttConnected])
    {
        [self.client disconnectWithOptions:nil invocationContext:@"disconnect" onCompletion:[[InvocationCallbacks alloc] init]];
    }
}

@end
