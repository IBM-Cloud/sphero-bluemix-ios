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
//  AppDelegate.h
//  IoTstarter
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <RobotKit/RobotKit.h>
#import "Constants.h"
#import "Messenger.h"
#import "IoTProfile.h"
#import "LoginViewController.h"
#import "IoTStarterViewController.h"
#import "RemoteViewController.h"
#import "ProfilesTableViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

// UI views
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) IoTStarterViewController *iotViewController;
@property (strong, nonatomic) RemoteViewController *remoteViewController;
@property (strong, nonatomic) ProfilesTableViewController *profileTableController;

@property (nonatomic) UIApplicationState appState;

@property (nonatomic) views currentView;

// IoT properties settable by user
//@property (strong, nonatomic) NSMutableDictionary *profiles;
@property (strong, nonatomic) NSMutableArray *profiles;
@property (strong, nonatomic) IoTProfile *currentProfile;
@property (strong, nonatomic) NSString *organization;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *authToken;

@property (nonatomic) CONNECTION_TYPE connectionType;

// Device specific properties
@property (nonatomic) BOOL isConnected;

// Total number of messages the app has published and received
@property NSInteger publishCount;
@property NSInteger receiveCount;

// Accelerometer related properties
@property (nonatomic) BOOL isAccelEnabled;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property CLLocation* latestLocation;
@property CMAcceleration latestAcceleration;
@property CMRotationRate latestRotation;
@property double latestRoll;
@property double latestPitch;
@property double latestYaw;
@property double sensorFrequency;
@property (strong, nonatomic) NSTimer* deviceTimer;

// Background task for continuing to run application while in background
//@property (nonatomic) UIBackgroundTaskIdentifier bgTask;

// Current color value
@property (strong, nonatomic) UIColor *color;

// For toggle light messages
@property (strong, nonatomic) AVCaptureSession *session;

// Store received "text" command messages for log view
@property (strong, nonatomic) NSMutableArray *messageLog;

- (void)storePropertiesToArchive;

- (void)switchToLoginView;
- (void)switchToIoTView;
- (void)switchToRemoteView;
- (void)switchToSpheroView;

- (void)startMotionManager;
- (void)stopMotionManager;

- (void)publishData:(NSString *)message event:(NSString *)event;

- (void)updateViewLabelsAndButtons;

/** Callbacks for responses to events */

/** Update background color when a color command message is received */
- (void)updateColor:(UIColor *)color;
- (void)resetSpheroOrigin;
- (void)updateSpheroColorWithRed:(double)red green:(double)green blue:(double)blue;
- (void)updateSpheroRollWithHeading:(double)heading velocity:(double)velocity;
- (void)rotateSpheroWithRotation:(double)degrees time:(double)seconds;

/** Turn the device torch on or off when a light command message is received */
- (void)toggleLight;

/** Add text command messages to the log view */
- (void)addLogMessage:(NSString *)textValue;

/* Sphero */
@property double robotHeading;
@property double robotVelocity;
@property BOOL robotOnline;
@property double lastPositionX;
@property double lastPositionY;
- (void)setupRobotConnection;
- (void)connectToRobot;
- (void)handleRobotOnline;
- (void)takePicture;

@property BOOL frontCamera;
@property int imageCount;
@property BOOL haveImage;
@property int currentTripId;

- (void)startTrip;
- (void)endTrip;

- (void)captureImage;

@property int calibrationState;
@property double calibrationYaw;

@end

#endif
