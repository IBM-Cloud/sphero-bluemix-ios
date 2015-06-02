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
//  MessageFactory.h
//  IoTstarter
//

#import <Foundation/Foundation.h>

@interface MessageFactory : NSObject

+ (NSString *)createAccelMessage:(double)accel_x
                         accel_y:(double)accel_y
                         accel_z:(double)accel_z
                            roll:(double)roll
                           pitch:(double)pitch
                             yaw:(double)yaw
                             lat:(double)lat
                             lon:(double)lon;

+ (NSString *)createTouchmoveMessage:(double)screen_x
                            screen_y:(double)screen_y
                             delta_x:(double)delta_x
                             delta_y:(double)delta_y
                               ended:(int)ended;

+ (NSString *)createTextMessage:(NSString *)text;

+ (NSString *)createGamepadMessage:(NSString *)button;

+ (NSString *)createGamepadMessage:(NSString *)button
                            dpad_x:(double)dpad_x
                            dpad_y:(double)dpad_y;

+ (NSString *)createSpheroCollisionMessage:(double)impact_axis_x
                             impact_axis_y:(double)impact_axis_y
                            impact_power_x:(double)impact_power_x
                            impact_power_y:(double)impact_power_y
                            impact_accel_x:(double)impact_accel_x
                            impact_accel_y:(double)impact_accel_y
                              impact_speed:(double)impact_speed
                         impact_position_x:(double)impact_position_x
                         impact_position_y:(double)impact_position_y
                          impact_timestamp:(NSTimeInterval)impact_timestamp;

+ (NSString *)createSpheroTelemetryMessage:(double)position_x
                                position_y:(double)position_y
                                velocity_x:(double)velocity_x
                                velocity_y:(double)velocity_y
                                   accel_x:(double)accel_x
                                   accel_y:(double)accel_y
                                   accel_z:(double)accel_z
                                      roll:(double)roll
                                     pitch:(double)pitch
                                       yaw:(double)yaw
                                       lat:(double)lat
                                       lon:(double)lon;

@end
