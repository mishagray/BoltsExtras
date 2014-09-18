//
//  BFTask+BoltsExtras.m
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


#import "BFTask+BoltsExtras.h"
#import <objc/runtime.h>

typedef id(^BoltsExtras_CancellationBlock)();
typedef id(^BoltsExtras_RepeatingTimerBlock)(BOOL * STOP);


@interface BFTask (BFTaskCompletionSource)
- (BOOL)trySetCancelled;
@end


@interface BECompletionToken ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) BoltsExtras_RepeatingTimerBlock timerBlock;
@end

@implementation BECompletionToken


+ (instancetype)token {
    return [[BECompletionToken alloc] init];
}

+ (BECompletionToken *)taskCompletionSource {
    return [[BECompletionToken alloc] init];
}

-(void)_cleanupTimer
{
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

-(void)_executeTimerBlock:(NSTimer *)inTimer{
    if ((self.timerBlock != nil) && (!self.task.isCompleted)) {
        BOOL STOP = NO;
        id ret = self.timerBlock(&STOP);
        if (STOP) {
            [self trySetResult:ret];
            [self _cleanupTimer];
        }
    }
}

- (BOOL)trySetCancelled
{
    [self _cleanupTimer];
    return [self.task trySetCancelled];
}
- (void)cancel
{
    [self _cleanupTimer];
    [self.task trySetCancelled];
}

- (void)dealloc
{
    [self _cleanupTimer];
}



@end



@implementation BFTask (BoltsExtras)

+ (instancetype)taskWithCompletionToken:(BECompletionToken*)token
{
    return token.task;
}


+ (instancetype)taskWithDelay:(int)millis completionToken:(BECompletionToken*)token
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, millis * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [token trySetResult:nil];
    });
    return token.task;
    
}

+ (instancetype)taskWithRepeatingTimeInterval:(NSTimeInterval)ti
                           withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                            completionToken:(BECompletionToken*)completionToken
{
    return [self taskWithRepeatingTimeInterval:ti withRepeatingBlock:repeatingTimerBlock completionToken:completionToken withExecutor:[BFExecutor immediateExecutor]];
}

+ (instancetype)taskWithRepeatingTimeInterval:(NSTimeInterval)ti
                                           withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                                            completionToken:(BECompletionToken*)tcs
                                            withExecutor:(BFExecutor *)executor
{
    [executor execute:^{
        tcs.timerBlock = [repeatingTimerBlock copy];
        tcs.timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                     target:tcs
                                                   selector:@selector(_executeTimerBlock:)
                                                   userInfo:nil repeats:YES];

    }];
    return tcs.task;
}


- (BOOL)isSuccessful
{
    if (self.isCompleted) {
        if ((self.error == nil) && (self.exception == nil) && (!self.cancelled)) {
            return YES;
        }
    }
    return NO;
}

- (id)debugQuickLookObject
{
    if (self.isCompleted) {
        if (self.isCancelled) {
            return [NSString stringWithFormat:@"%@ CANCELED",self];
        }
        else if (self.error != nil) {
            return [NSString stringWithFormat:@"%@ COMPLETED WITH ERROR:%@",self,[self.error localizedDescription]];
        }
        else if (self.exception != nil) {
            return [NSString stringWithFormat:@"%@ COMPLETED WITH EXCEPTION:%@",self,[self.exception description]];
        }
        else if (self.result != nil) {
            return [NSString stringWithFormat:@"%@ COMPLETED WITH RESULT:[%@]",self,self.result];
        }
        else {
            return [NSString stringWithFormat:@"%@ COMPLETED",self];
        }
    }
    else {
        return [NSString stringWithFormat:@"%@ NOT COMPLETED YET",self];
    }
}
@end


@implementation BFTaskCompletionSource (BoltsExtras)

- (BOOL)trySetCompletionValuesWithTask:(BFTask *)task
{
    if (!task.isCompleted) {
        [task continueWithBlock:^id(BFTask *finshedTask) {
            [self trySetCompletionValuesWithTask:finshedTask];
            return finshedTask;
        }];
        return YES;
    }
    else if (task.exception) {
        return [self trySetException:task.exception];
    }
    else if (task.error) {
        return [self trySetError:task.error];
    }
    else if (task.isCancelled) {
        return [self trySetCancelled];
    }
    else {
        return [self trySetResult:task.result];
    }
}

- (void)setCompletionValuesWithTask:(BFTask *)task
{
    if (![self trySetCompletionValuesWithTask:task]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot set the exception on a completed task."];
    }
}

@end
