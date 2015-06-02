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
//  RemoteViewController.m
//  IoTstarter
//

#import "RemoteViewController.h"
#import "AppDelegate.h"

@interface RemoteViewController ()

@property (strong, nonatomic) IBOutlet UIButton *aButton;
@property (strong, nonatomic) IBOutlet UIButton *bButton;
@property (strong, nonatomic) IBOutlet UIButton *xButton;
@property (strong, nonatomic) IBOutlet UIButton *yButton;

@property (strong, nonatomic) IBOutlet UIButton *upButton;
@property (strong, nonatomic) IBOutlet UIButton *downButton;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *startTripButton;
@property (weak, nonatomic) IBOutlet UIButton *endTripButton;

@end

@implementation RemoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    int r = self.aButton.layer.frame.size.height;
    
    self.aButton.layer.cornerRadius = r/2;
    self.aButton.layer.borderWidth = 1;
    [self.aButton setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    self.bButton.layer.cornerRadius = r/2;
    self.bButton.layer.borderWidth = 1;
    [self.bButton setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    self.xButton.layer.cornerRadius = r/2;
    self.xButton.layer.borderWidth = 1;
    [self.xButton setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    self.yButton.layer.cornerRadius = r/2;
    self.yButton.layer.borderWidth = 1;
    [self.yButton setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    r = self.dpad.layer.frame.size.height;
    self.dpad.layer.cornerRadius = r/2;
    self.dpad.layer.borderWidth = 1;
    self.dpad.layer.masksToBounds = YES;
    self.dpad.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [self.startTripButton setEnabled:true];
    self.startTripButton.backgroundColor = [UIColor colorWithRed:0.0078 green:0.414 blue:1.0 alpha:1.0];
    [self.endTripButton setEnabled:false];
    self.endTripButton.backgroundColor = [UIColor colorWithRed:0.0078 green:0.414 blue:1.0 alpha:0.2];
    
    self.calibrateHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startTrip:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate startTrip];

    [self.startTripButton setEnabled:false];
    self.startTripButton.backgroundColor = [UIColor colorWithRed:0.0078 green:0.414 blue:1.0 alpha:0.2];
    [self.endTripButton setEnabled:true];
    self.endTripButton.backgroundColor = [UIColor colorWithRed:0.0078 green:0.414 blue:1.0 alpha:1.0];
    
}
- (IBAction)endTrip:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate endTrip];

    [self.startTripButton setEnabled:true];
    self.startTripButton.backgroundColor = [UIColor colorWithRed:0.0078 green:0.414 blue:1.0 alpha:1.0];
    [self.endTripButton setEnabled:false];
    self.endTripButton.backgroundColor = [UIColor colorWithRed:0.0078 green:0.414 blue:1.0 alpha:0.2];
}

@end
