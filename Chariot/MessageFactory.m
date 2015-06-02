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
//  MessageFactory.m
//  IoTstarter
//

#import "AppDelegate.h"
#import "MessageFactory.h"
#import "Constants.h"

/**
 */

@implementation MessageFactory

/** 
 *  @param
 *  @return messageString
 */
+ (NSString *)createAccelMessage:(double)accel_x
                         accel_y:(double)accel_y
                         accel_z:(double)accel_z
                            roll:(double)roll
                           pitch:(double)pitch
                             yaw:(double)yaw
                             lat:(double)lat
                             lon:(double)lon
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_ACCEL_X: @(accel_x),
                                                JSON_ACCEL_Y: @(accel_y),
                                                JSON_ACCEL_Z: @(accel_z),
                                                JSON_ROLL: @(roll),
                                                JSON_PITCH: @(pitch),
                                                JSON_YAW: @(yaw),
                                                JSON_LAT: @(lat),
                                                JSON_LON: @(lon)
                                                }
    };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

+ (NSString *)createTouchmoveMessage:(double)screen_x
                            screen_y:(double)screen_y
                             delta_x:(double)delta_x
                             delta_y:(double)delta_y
                               ended:(int)ended
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_SCREEN_X: @(screen_x),
                                                JSON_SCREEN_Y: @(screen_y),
                                                JSON_DELTA_X: @(delta_x),
                                                JSON_DELTA_Y: @(delta_y),
                                                JSON_ENDED: @(ended)
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

+ (NSString *)createTextMessage:(NSString *)text
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_TEXT: text
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

+ (NSString *)createGamepadMessage:(NSString *)button
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_BUTTON: button
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

+ (NSString *)createGamepadMessage:(NSString *)button
                            dpad_x:(double)dpad_x
                            dpad_y:(double)dpad_y
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_BUTTON: button,
                                                JSON_DPAD_X: @(dpad_x),
                                                JSON_DPAD_Y: @(dpad_y)
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

+ (NSString *)createSpheroCollisionMessage:(double)impact_axis_x
                             impact_axis_y:(double)impact_axis_y
                            impact_power_x:(double)impact_power_x
                            impact_power_y:(double)impact_power_y
                            impact_accel_x:(double)impact_accel_x
                            impact_accel_y:(double)impact_accel_y
                              impact_speed:(double)impact_speed
                         impact_position_x:(double)impact_position_x
                         impact_position_y:(double)impact_position_y
                          impact_timestamp:(NSTimeInterval)impact_timestamp
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_IMPACT_AXIS_X: @(impact_axis_x),
                                                JSON_IMPACT_AXIS_Y: @(impact_axis_y),
                                                JSON_IMPACT_POWER_X: @(impact_power_x),
                                                JSON_IMPACT_POWER_Y: @(impact_power_y),
                                                JSON_IMPACT_ACCEL_X: @(impact_accel_x),
                                                JSON_IMPACT_ACCEL_Y: @(impact_accel_y),
                                                JSON_IMPACT_POSITION_X: @(impact_position_x),
                                                JSON_IMPACT_POSITION_Y: @(impact_position_y),
                                                JSON_IMPACT_SPEED: @(impact_speed),
                                                JSON_IMPACT_TIMESTAMP: @(impact_timestamp)
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

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
                                       lon:(double)lon
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_POSITION_X: @(position_x),
                                                JSON_POSITION_Y: @(position_y),
                                                JSON_VELOCITY_X: @(velocity_x),
                                                JSON_VELOCITY_Y: @(velocity_y),
                                                @"accel_x": @(accel_x),
                                                @"accel_y": @(accel_y),
                                                @"accel_z": @(accel_z),
                                                @"roll": @(roll),
                                                @"pitch": @(pitch),
                                                @"yaw": @(yaw),
                                                @"lat": @(lat),
                                                @"lon": @(lon)
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}

/*
+ (NSString *)createSpheroPictureMessage:(int)index
                                max:(int)max
                                data:(NSString*)data
{
    NSDictionary *messageDictionary = @{
                                        @"d": @{
                                                JSON_POSITION_X: @(position_x),
                                                JSON_POSITION_Y: @(position_y),
                                                JSON_VELOCITY_X: @(velocity_x),
                                                JSON_VELOCITY_Y: @(velocity_y)
                                                }
                                        };
    
    NSError *error;
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:&error];
    
    NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    return messageString;
}
*/

@end