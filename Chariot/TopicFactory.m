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
//  TopicFactory.m
//  IoTstarter
//

#import "AppDelegate.h"
#import "TopicFactory.h"
#import "Constants.h"

/** Use this if it turns out I have a decent number of topics to publish to
 * or subscribe from
 */

@implementation TopicFactory

/** Retrieve the event topic string for a specific event type.
 *  @param event The event type to get the topic string for
 *  @return topicString The event topic string for event
 */
+ (NSString *)getEventTopic:(NSString *)event
{
    NSString *topicString = [NSString stringWithFormat:IOTEventTopic, event, @"json"];
    return topicString;
}

/** Retrieve the event topic string for a specific event type.
 *  @param event The event type to get the topic string for
 *  @return topicString The event topic string for event
 */
+ (NSString *)getPictureEventTopic:(NSString *)event
{
    NSString *topicString = [NSString stringWithFormat:IOTEventTopic, event, @"png"];
    return topicString;
}

/** Retrieve the command topic string for a specific command type.
 *  @param command The command type to get the topic string for
 *  @return topicString The command topic string for command
 */
+ (NSString *)getCommandTopic:(NSString *)command
{
    NSString *topicString = [NSString stringWithFormat:IOTCommandTopic, command, @"json"];
    return topicString;
}

/** Retrieve the event topic string for a specific event type. Use m2m demo format instead
 *  of IoT format.
 *  @param event The event type to get the topic string for
 *  @return topicString The event topic string for event
 */
+ (NSString *)getM2MEventTopic:(NSString *)event
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *topicString = [NSString stringWithFormat:IOTM2MEventTopic, appDelegate.deviceID, event];
    return topicString;
}

/** Retrieve the command topic string for a specific command type. Use m2m demo format instead
 *  of IoT format.
 *  @param command The command type to get the topic string for
 *  @return topicString The event topic string for event
 */
+ (NSString *)getM2MCommandTopic:(NSString *)command
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *topicString = [NSString stringWithFormat:IOTM2MCommandTopic, appDelegate.deviceID, command];
    return topicString;
}

@end
