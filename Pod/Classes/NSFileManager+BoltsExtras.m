//
//  NSFileManager+BoltsExtras.m
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Michael Gray (@mishagray)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "NSFileManager+BoltsExtras.h"
#import "Bolts.h"

static BFExecutor *s_executorForFileManager = nil;

@implementation NSFileManager (BoltsExtras)

+ (BFExecutor*) defaultExecutor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (s_executorForFileManager == nil) {
            s_executorForFileManager = [BFExecutor executorWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        }
    });
    return s_executorForFileManager;
}

+ (void) setDefaultExecutor:(BFExecutor*)executor
{
    s_executorForFileManager = executor;
}

- (BFTask*)removeItemAtURL:(NSURL *)path
{
    return [self removeItemAtURL:path withExecutor:[NSFileManager defaultExecutor]];
}
- (BFTask*)contentsOfDirectoryAtURL:(NSURL *)url
         includingPropertiesForKeys:(NSArray *)keys
                            options:(NSDirectoryEnumerationOptions)mask
{
    return [self contentsOfDirectoryAtURL:url includingPropertiesForKeys:keys options:mask withExecutor:[NSFileManager defaultExecutor]];
}




- (BFTask*)removeItemAtURL:(NSURL *)path withExecutor:(BFExecutor *)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        NSError * error = nil;
 
        [self removeItemAtURL:path error:&error];
        if (error != nil) {
            tcs.error = error;
        }
        else {
            [tcs trySetResult:nil];
        }
    }];
    
    return tcs.task;
}

- (BFTask*)contentsOfDirectoryAtURL:(NSURL *)url
         includingPropertiesForKeys:(NSArray *)keys
                            options:(NSDirectoryEnumerationOptions)mask
                       withExecutor:(BFExecutor*)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        NSError * error = nil;
        
        NSArray * contents = [self contentsOfDirectoryAtURL:url includingPropertiesForKeys:keys options:mask error:&error];
        if (error != nil) {
            tcs.error = error;
        }
        else {
            [tcs trySetResult:contents];
        }
    }];
    return tcs.task;
   
}

@end