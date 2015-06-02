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
 *    Bryan Boyd
 *    Mike Robertson
 */

#import "Trace.h"

@implementation Trace

@synthesize traceLevel;
- (Trace *)initWithTraceLevel:(TraceLevel)level
{
    self = [super init];
    traceLevel = level;
    return self;
}

/** Emit a trace message at the TraceLevelDebug level.
 *  @param message A string value of the trace message
 */
- (void)traceDebug: (NSString*)message
{
    if (self.traceLevel <= TraceLevelDebug)
    {
        NSLog(@"[DEBUG]: %@", message);
    }
}

/** Emit a trace message at the TraceLevelLog level.
 *  @param message A string value of the trace message
 */
- (void)traceLog:   (NSString*)message
{
    if (self.traceLevel <= TraceLevelLog)
    {
        NSLog(@"[LOG]: %@", message);
    }
}

/** Emit a trace message at the TraceLevelInfo level.
 *  @param message A string value of the trace message
 */
- (void)traceInfo:  (NSString*)message
{
    if (self.traceLevel <= TraceLevelInfo)
    {
        NSLog(@"[INFO]: %@", message);
    }
}

/** Emit a trace message at the TraceLevelWarn level.
 *  @param message A string value of the trace message
 */
- (void)traceWarn:  (NSString*)message
{
    if (self.traceLevel <= TraceLevelWarning)
    {
        NSLog(@"[WARN]: %@", message);
    }
}

/** Emit a trace message at the TraceLevelError level.
 *  @param message A string value of the trace message
 */
- (void)traceError: (NSString*)message
{
    if (self.traceLevel <= TraceLevelError)
    {
        NSLog(@"[ERROR]: %@", message);
    }
}

@end
