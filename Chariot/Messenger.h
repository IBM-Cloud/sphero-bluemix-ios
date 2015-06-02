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
//  Messenger.h
//  IoTstarter
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "MqttOCClient.h"
#import "TopicFactory.h"
#import "MessageFactory.h"
#import "Callbacks.h"
#import "Trace.h"

#define PAHO_TRACE 0

@interface Messenger : NSObject

@property (strong, nonatomic) MqttClient *client;
@property (strong, nonatomic) id<MqttTraceHandler> tracer;

+ (id)sharedMessenger;

- (void)connectWithHost:(NSString *)host
                   port:(int)port
               clientId:(NSString *)clientId;

- (void)publish:(NSString *)topic
        payload:(NSString *)payload
            qos:(int)qos
       retained:(BOOL)retained;

- (void)subscribe:(NSString *)topicFilter
              qos:(int)qos;

- (void)unsubscribe:(NSString *)topicFilter;

- (void)disconnect;

@end
