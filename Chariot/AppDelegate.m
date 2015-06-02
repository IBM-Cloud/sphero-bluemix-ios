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
//  AppDelegate.m
//  IoTstarter
//

#import "AppDelegate.h"
#import <RobotKit/RobotKit.h>
#import "SpheroViewController.h"
#import "MessageFactory.h"

@implementation AppDelegate

/** Load persistent data from application archive file.
 *  < 1.3.0, persistent data will contain:
 *    - Organization
 *    - DeviceID
 *    - Auth Token
 *  > 1.3.0, persistent data will contain connection profiles:
 *    - NSMutableDictionary objects containing organization, deviceID, auth token, profile name
 *    - The key is the profile name
 *  @return dataDict An NSMutableDictionary object containing the retrieved properties
 */
- (NSMutableDictionary *)loadPropertiesFromArchive
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    NSString *_dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingString:IOTArchiveFileName]];
    NSMutableDictionary *dataDict = nil;
    
    if ([filemgr fileExistsAtPath:_dataFilePath])
    {
        dataDict = [NSKeyedUnarchiver unarchiveObjectWithFile:_dataFilePath];
    }
    if ([dataDict isKindOfClass:[NSMutableArray class]])
    {
        return nil;
    }
    return dataDict;
}

/** Store persistent data to application archive file.
 *  Persistent data currently includes:
 *   Device ID
 *   Organization ID
 *   Auth Token
 */
- (void)storePropertiesToArchive
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    NSString *_dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingString:IOTArchiveFileName]];
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    
    NSInteger profileCount = self.profiles.count;
    
    if (profileCount == 0)
    {
        // Create default profile with current settings if no profile exists
        IoTProfile *profile = [[IoTProfile alloc] initWithName:@"default" organization:self.organization deviceID:self.deviceID authorizationToken:self.authToken];
        self.currentProfile = profile;
        [self.profiles addObject:self.currentProfile];
        profileCount = self.profiles.count;
    }
    
    int index;
    for (index=0; index < profileCount; index++)
    {
        IoTProfile *profile = [self.profiles objectAtIndex:index];
        NSMutableDictionary *profileDictionary = [profile createDictionaryFromProfile];
        [dataDict setObject:profileDictionary forKey:profile.profileName];
    }
    
    // Store the name of the current profile so that we can reload the settings from
    // this profile automatically after restart.
    [dataDict setObject:[self.currentProfile profileName] forKey:@"iot:selectedprofile"];
    
    [NSKeyedArchiver archiveRootObject:dataDict toFile:_dataFilePath];
}

/** Populate settings based on properties loaded from archive.
 *  Compatibility - Create default profile if stored properties were deviceID, org, auth token.
 */
- (void)loadProfilesFromArchive
{
    // Load stored application data.
    NSMutableDictionary *data = [self loadPropertiesFromArchive];
    if (data != nil)
    {
        // The last selected profile is stored under key "iot:selectedprofile".
        // If this key exists, profileName will be the name of the last selected
        // profile.
        NSString *profileName;
        if ((profileName = [data objectForKey:@"iot:selectedprofile"]) == nil)
        {
            profileName = @"";
        }
        
        if ([data objectForKey:IOTDeviceID] != nil)
        {
            // Data from older app version -- no profile
            NSString *deviceID = [data objectForKey:IOTDeviceID];
            NSString *organization = [data objectForKey:IOTOrganization];
            NSString *authToken = [data objectForKey:IOTAuthToken];
            self.currentProfile = [[IoTProfile alloc] initWithName:@"default" organization:organization deviceID:deviceID authorizationToken:authToken];
            [self.profiles addObject:self.currentProfile];
            [self storePropertiesToArchive];
        }
        else
        {
            // Found profile data
            NSString *key;
            NSEnumerator *keys = [data keyEnumerator];
            while ((key = [keys nextObject]) != nil)
            {
                // Skip the selectedprofile property -- its just a string, not a profile.
                if ([key isEqualToString:@"iot:selectedprofile"])
                {
                    continue;
                }
                
                // Load the stored profile
                NSMutableDictionary *profileDictionary = [data objectForKey:key];
                IoTProfile *profile = [[IoTProfile alloc] initWithName:key dictionary:profileDictionary];
                [self.profiles addObject:profile];

                // If this profile matches the "iot:selectedprofile" value,
                // then set it to the current profile.
                if ([profileName isEqualToString:[profile profileName]])
                {
                    self.currentProfile = profile;
                }
            }
        }
        
        // Set the current application properties based on the last selected profile.
        if (self.currentProfile != nil)
        {
            self.authToken = [self.currentProfile authorizationToken];
            self.organization = [self.currentProfile organization];
            self.deviceID = [self.currentProfile deviceID];
        }
    }
}

/*- (void)fillOldTestProperties
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    NSString *_dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingString:IOTArchiveFileName]];
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    
    [dataDict setObject:@"" forKey:@"organization"];
    [dataDict setObject:@"AB12CD34EF56" forKey:@"deviceid"];
    [dataDict setObject:@"" forKey:@"authtoken"];

    [NSKeyedArchiver archiveRootObject:dataDict toFile:_dataFilePath];
}*/

/** Initialize the application. Load stored settings. Set the appropriate
 *  storyboard.
 *  @return YES is returned in all cases
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    // Override point for customization after application launch.
    
    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Initialize some application settings
    self.isConnected = NO;
    self.publishCount = 0;
    self.receiveCount = 0;
    self.isAccelEnabled = NO;
    self.sensorFrequency = IOTSensorFreqDefault;
    
    self.messageLog = [[NSMutableArray alloc] init];
    self.color = [UIColor colorWithRed:104 green:109 blue:115 alpha:1.0];
    
    self.profiles = [[NSMutableArray alloc] init];
    self.organization = @"";
    self.deviceID = @"";
    self.authToken = @"";
    
    self.calibrationYaw = 0;
    self.calibrationState = 0;
    
    //[self fillOldTestProperties];
    
    [self loadProfilesFromArchive];
    
    [self loadStoryboard];
    
    // Prompt to allow user notifications.
    /*if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }*/
    
    self.robotOnline = NO;
    return YES;
}

- (void)switchToLoginView
{
    [self.tabController setSelectedIndex:0];
}

- (void)switchToRemoteView
{
    [self.tabController setSelectedIndex:1];
}

- (void)switchToCameraView
{
    [self.tabController setSelectedIndex:2];
}

/** Enable the accelerometer and motion detector on the device.
 *  Interval for updates is 0.2 seconds.
 */
- (void)startMotionManager
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if (!self.motionManager)
    {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    self.motionManager.accelerometerUpdateInterval = self.sensorFrequency;
    self.motionManager.gyroUpdateInterval = self.sensorFrequency;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self updateAccelerationData:accelerometerData.acceleration];
                                                 if(error)
                                                 {
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion *motionData, NSError *error) {
                                                [self updateAttitudeData:motionData.attitude.roll pitch:motionData.attitude.pitch yaw:motionData.attitude.yaw];
                                            }];
    
    if (!self.locationManager)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if (IS_OS_8_OR_LATER) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [self.locationManager startUpdatingLocation];
    }
    
    if (self.deviceTimer)
    {
        [self.deviceTimer invalidate];
    }
    
    self.deviceTimer = [NSTimer scheduledTimerWithTimeInterval:self.sensorFrequency target:self selector:@selector(accelerometerTimerCallback) userInfo:nil repeats:YES];
}

/** Disable the accelerometer and motion detector.
 */
- (void)stopMotionManager
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
    [self.locationManager stopUpdatingLocation];
    
    if (self.deviceTimer)
    {
        [self.deviceTimer invalidate];
    }
}

- (void)updateAccelerationData:(CMAcceleration)acceleration
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    self.latestAcceleration = acceleration;
}

- (void)updateAttitudeData:(double)roll pitch:(double)pitch yaw:(double)yaw
{
    //NSLog(@"%s:%d entered", __func__, __LINE__);
    self.latestRoll = roll;
    self.latestPitch = pitch;
    self.latestYaw = yaw;
    
    int isCalibrating = [RUICalibrateGestureHandler isCalibrating] ? 1 : 0;
    if (isCalibrating != self.calibrationState && isCalibrating == 0) {
        // new calibration, set calibration yaw
        self.calibrationYaw = self.latestYaw;
        NSLog(@"setting calibrationYaw: %f", self.calibrationYaw);
    }
    self.calibrationState = isCalibrating;
    //NSLog(@"yaw: %f, isCalibrating: %d", yaw, isCalibrating);
}

/** Publish accelerometer data.
 */
- (void)accelerometerTimerCallback
{
    //NSLog(@"%s:%d entered", __func__, __LINE__);
    // TODO: More decimal places on attitude values
    NSString *messageData = [MessageFactory createAccelMessage:self.latestAcceleration.x
                                                       accel_y:self.latestAcceleration.y
                                                       accel_z:self.latestAcceleration.z
                                                          roll:self.latestRoll
                                                         pitch:self.latestPitch
                                                           yaw:self.latestYaw
                                                           lat:self.latestLocation.coordinate.latitude
                                                           lon:self.latestLocation.coordinate.longitude];
    
    //[self.iotViewController updateAccelLabels];
    //[self publishData:messageData event:IOTAccelEvent];
}

/** Publish an MQTT Message with data message for IoT Event event
 *  @param message The data to be sent
 *  @param event The event to publish the data to
 */
- (void)publishData:(NSString *)message event:(NSString *)event
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    Messenger *messenger = [Messenger sharedMessenger];
    if (messenger.client.isConnected == NO)
    {
        NSLog(@"Mqtt Client not connected. Swipes will be ignored");
        return;
    }
    
    if (self.connectionType == QUICKSTART)
    {
        if ([event isEqualToString:IOTAccelEvent])
        {
            // Publish accel message as status event
            self.publishCount++;
            [self.iotViewController updateMessageCounts];
            [messenger publish:[TopicFactory getEventTopic:IOTStatusEvent] payload:message qos:0 retained:NO];
        }
        else
        {
            // If quickstart, only allow accel events to be published.
            return;
        }
    }
    else
    {
        // Publish the message on the desired event
        self.publishCount++;
        [self.iotViewController updateMessageCounts];
        if (self.connectionType == M2M)
        {
            [messenger publish:[TopicFactory getM2MEventTopic:event] payload:message qos:0 retained:NO];
        }
        else
        {
            if ([event isEqualToString:IOTPictureDataEvent]) {
                [messenger publish:[TopicFactory getPictureEventTopic:event] payload:message qos:0 retained:NO];
            } else {
                [messenger publish:[TopicFactory getEventTopic:event] payload:message qos:0 retained:NO];
            }
            
        }
    }
}

- (void)updateViewLabelsAndButtons
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    if (self.loginViewController != nil) {
        [self.loginViewController updateViewLabels];
    }
    if (self.iotViewController != nil) {
        [self.iotViewController updateViewLabels];
    }
}

/** Update the background color of the IoT view.
 *  @param color The color to update to.
 */
- (void)updateColor:(UIColor *)color
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    self.color = color;
    [self.iotViewController updateBackgroundColor:self.color];
}

- (void)updateSpheroColorWithRed:(double)red green:(double)green blue:(double)blue
{
    if (self.robotOnline) {
        [RKRGBLEDOutputCommand sendCommandWithRed:red green:green blue:blue];
    } else {
        NSLog(@"not connected to robot :-(");
    }
}

- (void)updateSpheroRollWithHeading:(double)heading velocity:(double)velocity
{
    self.robotHeading = heading;
    self.robotVelocity = velocity;
    [self rollSpheroCallback];
}

- (void)rotateSpheroWithRotation:(double)degrees time:(double)seconds
{
    RKMacroObject *macro = [RKMacroObject new];
    [macro addCommand:[RKMCRotateOverTime commandWithRotation:degrees delay:seconds]];
    [macro playMacro];
}

- (void)rollSpheroCallback
{
    if (self.robotOnline) {
        if (self.robotVelocity == 0) {
            [RKRollCommand sendStop];
        } else {
            [RKRollCommand sendCommandWithHeading:self.robotHeading velocity:self.robotVelocity];
        }
    }
}

- (void)startTrip
{
    self.currentTripId = rand() % 10000;
    NSNumber *timestamp = [NSNumber numberWithDouble:floor((1000 *[[NSDate date] timeIntervalSince1970]))];
   [self publishData:[NSString stringWithFormat:@"{\"tripId\":%d,\"driverId\":\"v1\",\"time\":%@}", self.currentTripId, [timestamp stringValue]] event:@"startTripRequest"];
}

- (void)endTrip
{
    NSNumber *timestamp = [NSNumber numberWithDouble:floor((1000 *[[NSDate date] timeIntervalSince1970]))];
    [self publishData:[NSString stringWithFormat:@"{\"tripId\":%d,\"driverId\":\"v1\",\"time\":%@}", self.currentTripId, [timestamp stringValue]] event:@"stopTripRequest"];
}

/** Turn the device torch on or off. If no torch is present, display an alert saying so.
 */
- (void)toggleLight
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device isTorchAvailable] == NO)
    {
        NSLog(@"Torch not available");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Torch not available" message:@"This feature is not supported on this device." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
        return;
    }
    if (device.torchMode == AVCaptureTorchModeOff)
    {
        self.session = [[AVCaptureSession alloc] init];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [self.session addInput:input];
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [self.session addOutput:output];
        [self.session beginConfiguration];
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        [device unlockForConfiguration];
        [self.session commitConfiguration];
        [self.session startRunning];
    }
    else
    {
        [self.session stopRunning];
        self.session = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // When the application is entering the background we need to close the connection to the robot
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self storePropertiesToArchive];
    self.appState = UIApplicationStateBackground;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[self connectToRobot];
    self.appState = UIApplicationStateActive;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Store application data to be saved.
    [self storePropertiesToArchive];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"received notification.");
}

- (void)connectToRobot
{
    NSLog(@"***** connectToRobot");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl])
    {
        NSLog(@"***** openRobotConnection");
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];
    }else
    {
        NSLog(@"***** controlConnectedRobot");
        BOOL rc = [[RKRobotProvider sharedRobotProvider] controlConnectedRobot];
        NSLog(@"***** controlConnectedRobot returned %d", rc);
    }
}

- (void)handleRobotOnline
{
    NSLog(@"***** handleRobotOnline");
    /*The robot is now online, we can begin sending commands*/
    if(!self.robotOnline) {
        /* Send commands to Sphero Here: */
        [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
        
        // register for collision detection (tuned for ball-to-ball)
        
        [RKConfigureCollisionDetectionCommand sendCommandForMethod:RKCollisionDetectionMethod1
                                                        xThreshold:60
                                                   xSpeedThreshold:0
                                                        yThreshold:60
                                                   ySpeedThreshold:0
                                                  postTimeDeadZone:200];
        
        
        // register for collision detection (tuned for wall hits only)
        /*
        [RKConfigureCollisionDetectionCommand sendCommandForMethod:RKCollisionDetectionMethod1
                                                        xThreshold:100
                                                   xSpeedThreshold:0
                                                        yThreshold:85
                                                   ySpeedThreshold:0
                                                  postTimeDeadZone:40];
        */
        
        RKDataStreamingMask sensorMask = RKDataStreamingMaskLocatorAll | RKDataStreamingMaskAccelerometerFilteredAll | RKDataStreamingMaskIMUAnglesFilteredAll;
        [RKSetDataStreamingCommand sendCommandWithSampleRateDivisor:133       // 3 msg/sec
                                                       packetFrames:1
                                                         sensorMask:sensorMask
                                                        packetCount:0];
        
        [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self
                                                             selector:@selector(handleAsyncData:)];
        
        [RKConfigureLocatorCommand sendCommandForFlag:RKConfigureLocatorRotateWithCalibrateFlagOff newX:0 newY:0 newYaw:0];
        
        // start roll loop
        NSTimer* timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(rollSpheroCallback) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    [self switchToRemoteView];
    self.robotOnline = YES;
}

- (void)resetSpheroOrigin
{
    [RKConfigureLocatorCommand sendCommandForFlag:RKConfigureLocatorRotateWithCalibrateFlagOff newX:0 newY:0 newYaw:0];
}

- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData
{
    if ([asyncData isKindOfClass:[RKCollisionDetectedAsyncData class]]) {
        RKCollisionDetectedAsyncData *collisionData = (RKCollisionDetectedAsyncData *)asyncData;
        NSString *messageData = [MessageFactory createSpheroCollisionMessage:collisionData.impactAxis.x
                                                               impact_axis_y:collisionData.impactAxis.y
                                                              impact_power_x:collisionData.impactPower.x
                                                              impact_power_y:collisionData.impactPower.y
                                                              impact_accel_x:collisionData.impactAcceleration.x
                                                              impact_accel_y:collisionData.impactAcceleration.y
                                                                impact_speed:collisionData.impactSpeed
                                                           impact_position_x:self.lastPositionX
                                                           impact_position_y:self.lastPositionY
                                                            impact_timestamp:collisionData.impactTimeStamp];
        
        [self publishData:messageData event:IOTSpheroCollisionEvent];
    } else if ([asyncData isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)asyncData;
        RKDeviceSensorsData *sensorData = [sensorsAsyncData.dataFrames lastObject];
        RKAccelerometerData *accelerometerData = sensorData.accelerometerData;
        RKAttitudeData *attitudeData = sensorData.attitudeData;
        
        self.lastPositionX = sensorData.locatorData.position.x;
        self.lastPositionY = sensorData.locatorData.position.y;
        
        NSString *messageData = [MessageFactory createSpheroTelemetryMessage:sensorData.locatorData.position.x
                                                                  position_y:sensorData.locatorData.position.y
                                                                  velocity_x:sensorData.locatorData.velocity.x
                                                                  velocity_y:sensorData.locatorData.velocity.y
                                                                     accel_x:sensorData.accelerometerData.acceleration.x
                                                                     accel_y:sensorData.accelerometerData.acceleration.y
                                                                     accel_z:sensorData.accelerometerData.acceleration.z
                                                                        roll:sensorData.attitudeData.roll
                                                                       pitch:sensorData.attitudeData.pitch
                                                                         yaw:sensorData.attitudeData.yaw
                                                                         lat:self.latestLocation.coordinate.latitude
                                                                         lon:self.latestLocation.coordinate.longitude];
        [self publishData:messageData event:IOTSpheroTelemetryEvent];
    }
}

- (void)setupRobotConnection
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    NSLog(@"***** openRobotConnection");
    [[RKRobotProvider sharedRobotProvider] openRobotConnection];
}

- (void)takePicture
{
    [self switchToCameraView];
    SpheroViewController* spheroVC = [self.tabController.viewControllers objectAtIndex:4];
    [spheroVC captureImage:self];
}

/* Load the appropriate storyboard file based on device type.
 *   iPad         - iPad.storyboard
 *   3.5in iPhone - iPhone.storyboard
 *   4.0in iPhone - Main.storyboard
 */
- (void)loadStoryboard
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIStoryboard *storyboard = nil;
    if (screenSize.height == 568)
    {
        // Main.storyboard - 4in iPhone
        storyboard = [UIStoryboard storyboardWithName:@"Second_iPhone" bundle:nil];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        // iPad.storyboard - iPad
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    else
    {
        // iPhone.storyboard - 3.5in iPhone
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    self.tabController = [storyboard instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabController;
    [self.window makeKeyAndVisible];
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.latestLocation = newLocation;
}

@end
