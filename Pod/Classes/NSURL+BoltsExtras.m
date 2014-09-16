//
//  NSURL+BoltsExtras.m
//  Pods
//
//  Created by Michael Gray on 9/16/14.
//
//

#import "NSURL+BoltsExtras.h"
#import "Bolts.h"


@implementation NSURL (BoltsExtras)

- (BFTask*)getResourceValueForKey:(NSString *)key
{
    return [self getResourceValueForKey:key withExecutor:[BFExecutor immediateExecutor]];
}

- (BFTask*)getResourceValueForKey:(NSString *)key withExecutor:(BFExecutor*)executor;
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    
    [executor execute:^{
        id value;
        NSError * error = nil;
        if ([self getResourceValue:&value forKey:key error:&error]) {
            [tcs trySetResult:value];
        }
        else {
            NSAssert(error != nil, @"Why is getResourceValue failing without an error!?!?");
            [tcs trySetError:error];
        }
    }];
    return tcs.task;
}


@end
