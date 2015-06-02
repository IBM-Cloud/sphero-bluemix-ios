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
//  Callbacks.h
//  IoTstarter
//

#import <Foundation/Foundation.h>
#import "Messenger.h"

@interface InvocationCallbacks : NSObject <InvocationComplete>

- (void)onSuccess:(NSObject *)invocationContext;
- (void)onFailure:(NSObject *)invocationContext
        errorCode:(int)errorCode
     errorMessage:(NSString *)errorMessage;

@end

@interface GeneralCallbacks : NSObject <MqttCallbacks>

- (void)onConnectionLost:(NSObject *)invocationContext
            errorMessage:(NSString *)errorMessage;
- (void)onMessageArrived:(NSObject *)invocationContext
                 message:(MqttMessage *)message;
- (void)onMessageDelivered:(NSObject *)invocationContext
                 messageId:(int)msgId;

@end