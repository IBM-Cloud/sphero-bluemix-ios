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
//  IoTProfile.m
//  IoTstarter
//

#import "AppDelegate.h"
#import "Constants.h"
#import "IoTProfile.h"

/**
 */

@implementation IoTProfile

- (id)initWithName:(NSString *)name dictionary:(NSMutableDictionary *)dictionary
{
    if (self = [super init])
    {
        self.profileName = name;
        self.organization = [dictionary objectForKey:IOTOrganization];
        self.deviceID = [dictionary objectForKey:IOTDeviceID];
        self.authorizationToken = [dictionary objectForKey:IOTAuthToken];
    }
    return self;
}

- (id)initWithName:(NSString *)name
      organization:(NSString *)organization
          deviceID:(NSString *)deviceID
authorizationToken:(NSString *)authorizationToken
{
    if (self = [super init])
    {
        self.profileName = name;
        self.organization = organization;
        self.deviceID = deviceID;
        self.authorizationToken = authorizationToken;
    }
    return self;
}

- (NSMutableDictionary *)createDictionaryFromProfile
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:self.organization forKey:IOTOrganization];
    [dictionary setObject:self.deviceID forKey:IOTDeviceID];
    [dictionary setObject:self.authorizationToken forKey:IOTAuthToken];
    
    return dictionary;
}

@end