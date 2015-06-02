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
//  DPadView.m
//  IoTstarter
//
//  Created by Mike Robertson on 11/11/14.
//  Copyright (c) 2014 Mike Robertson. All rights reserved.
//

#import "DPadView.h"
#import "Messenger.h"

@interface DPadView ()
@end

@implementation DPadView
{
    CGPoint handle;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        handle = CGPointMake(0, 0);
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.remoteViewController setDpad:self];
    }
    return self;
}

/** Respond to the initial event for a user touching the screen.
 *  This does not send a message, but initializes the previous X and Y values
 *  to be used in touchesMoved.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s:%d entered", __func__, __LINE__);
    UITouch *touch = [touches anyObject];
    handle = CGPointMake([touch locationInView:self].x - 150, 300 - [touch locationInView:self].y - 150);
    //[path moveToPoint:[touch locationInView:self]];
    NSLog(@"*****************");
    NSLog(@"X: %f, Y: %f", handle.x, handle.y);
    NSLog(@"*****************");
    [self updateHandle];
}

/** Respond to incoming events as a user is touching the screen.
 *  Publish a message for each event.
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"%s:%d entered", __func__, __LINE__);
    UITouch *touch = [touches anyObject];
    handle = CGPointMake([touch locationInView:self].x - 150, 300 - [touch locationInView:self].y - 150);
    //[path moveToPoint:[touch locationInView:self]];
    //NSLog(@"*****************");
    //NSLog(@"X: %f, Y: %f", handle.x, handle.y);
    //NSLog(@"*****************");
    [self updateHandle];
    //[self publishTouchMove:touches ended:NO];
}

/** Respond to the final event for a user touching the screen.
 *  Publish a message with the ended flag set to true indicating
 *  the final message of the touch.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"%s:%d entered", __func__, __LINE__);
    handle = CGPointMake(0, 0);
    [self updateHandle];
}

/** Publish the touchmove message. The message contains the current x,y coordinates,
 *  as well as the delta values between the current and previous coordinates.
 *  @param touches The set of touch events so far.
 *  @param ended Indicates whether this is the final message of the touch.
 */
- (void)updateHandle
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //Messenger *messenger = [Messenger sharedMessenger];
    
  //  UITouch *touch = [touches anyObject];
//    [self setNeedsDisplay];
    //float endX = [touch locationInView:self].x;
    //float endY = [touch locationInView:self].y;
    
    //CGRect frame = self.frame;
    //float leftX = frame.size.width / 2;
    //float topY = frame.size.height / 2;
    
    float offsetYaw = (appDelegate.latestYaw - appDelegate.calibrationYaw) * 180 / M_PI;
    
    float mag = sqrt(handle.x*handle.x + handle.y*handle.y) / 150;
    float angleInDegrees = ((atan2f(handle.y, -1*handle.x) * 180 / M_PI) - 90) - offsetYaw;
    if (angleInDegrees < 0) { angleInDegrees += 360; }
    if (angleInDegrees > 360) { angleInDegrees -= 360; }
    if (mag > 1.0) { mag = 0.0; }
    NSLog(@"mag: %f, angle: %f, offsetYaw: %f", mag, angleInDegrees, offsetYaw);
    
    [self setNeedsDisplay];
    
    [appDelegate updateSpheroRollWithHeading:angleInDegrees velocity:mag];
    
//    NSString *messageData = [MessageFactory createGamepadMessage:directionString
    //                                                      dpad_x:deltaX
      //                                                    dpad_y:deltaY];
    
  //  [appDelegate publishData:messageData event:IOTGamepadEvent];
}

/** Respond to the event of a touch being cancelled.
 */
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"%s:%d entered", __func__, __LINE__);
    handle = CGPointMake(0, 0);
    [self updateHandle];

}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw line
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 150.0, 150.0);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat component[] = {1.0, 1.0, 1.0, 1.0};
    CGColorRef color = CGColorCreate(space, component);
    CGContextSetStrokeColorWithColor(ctx, color);
    CGContextAddLineToPoint(ctx, 150 + handle.x, 150 - handle.y);
    CGContextSetLineWidth(ctx, 5);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    NSLog(@"%f, %f", handle.x, handle.y);
    
    // draw circle
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, 150 + handle.x, 150 - handle.y, 10.0, 0, 2*M_PI, 0);
    CGFloat green_component[] = {0.0, 1.0, 0.0, 1.0};
    color = CGColorCreate(space, green_component);
    CGContextSetStrokeColorWithColor(ctx, color);
    CGContextStrokePath(ctx);
    CGColorSpaceRelease(space);
    CGColorRelease(color);

}


@end
