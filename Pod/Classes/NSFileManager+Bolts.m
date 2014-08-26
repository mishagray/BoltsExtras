//
//  NSFileManager+Bolts.m
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import "NSFileManager+Bolts.h"

@implementation NSFileManager (Bolts)

+ (BFExecutor*) defaultExecutor
{
    static BFExecutor *_executorForFileManager = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _executorForFileManager = [BFExecutor executorWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    });
    return _executorForFileManager;
}


- (BFTask*)removeItemAtURL:(NSURL *)path
{
    // Delete each dataset
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [[NSFileManager defaultExecutor] execute:^{
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

@end
