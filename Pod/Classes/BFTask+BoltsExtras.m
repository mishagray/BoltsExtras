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

typedef void(^BoltsExtras_CancelationBlock)();
typedef id(^BoltsExtras_RepeatingTimerBlock)(BOOL * STOP);


@interface BFTask (BFTaskCompletionSource)
- (BOOL)trySetCancelled;
@end


@interface BoltsExtrasBFTaskCompletionSource : BFTaskCompletionSource;

@end

@interface BoltsExtrasBFTaskCompletionSource ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) BoltsExtras_RepeatingTimerBlock timerBlock;
@end

@implementation BoltsExtrasBFTaskCompletionSource


+ (BFTaskCompletionSource *)taskCompletionSource {
    return [[BoltsExtrasBFTaskCompletionSource alloc] init];
}

-(void)_cleanupTimer
{
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    self.timer = nil;
    self.timerBlock = nil;
}

-(void)_executeTimerBlock:(NSTimer *)inTimer{
    if ((self.timerBlock != nil) && (!self.task.isCompleted)) {
        BOOL STOP = NO;
        id ret = self.timerBlock(&STOP);
        if (STOP) {
            [self _cleanupTimer];
            [self trySetResult:ret];
        }
    }
}

- (void)dealloc
{
    [self _cleanupTimer];
}

@end

@implementation BFTask (BoltsExtras)


+ (instancetype)cancelableTaskWithDelay:(int)millis {
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, millis * NSEC_PER_MSEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [tcs trySetResult:nil];
    });
    return tcs.task;
}


+ (instancetype)cancelableTaskWithRepeatingTimeInterval:(NSTimeInterval)ti
                                     withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                                          onCancelBlock:(void (^)())onCancelBlock
{
    return [self cancelableTaskWithRepeatingTimeInterval:ti
                                      withRepeatingBlock:repeatingTimerBlock
                                           onCancelBlock:onCancelBlock
                                            withExecutor:[BFExecutor immediateExecutor]];
}

+ (instancetype)cancelableTaskWithRepeatingTimeInterval:(NSTimeInterval)ti
                                           withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                                                onCancelBlock:(void (^)())onCancelBlock
                                            withExecutor:(BFExecutor *)executor
{
    BoltsExtrasBFTaskCompletionSource *tcs = [BoltsExtrasBFTaskCompletionSource taskCompletionSource];
 
    [executor execute:^{

    
        tcs.timerBlock = [repeatingTimerBlock copy];
        tcs.timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                  target:tcs
                                                selector:@selector(_executeTimerBlock:)
                                                userInfo:nil repeats:YES];
        __weak BoltsExtrasBFTaskCompletionSource * weaktcs = tcs;
       [tcs.task setOnCancelBlock:^{
            [weaktcs _cleanupTimer];
            if (onCancelBlock != NULL) {
                [executor execute:onCancelBlock];
            }
        }];
    }];
    return tcs.task;
}

static NSString *CANCEL_BLOCK_KEY = @"com.pushleaf.BoltsExtras.BFTask.CANCEL_BLOCK";

- (void)setOnCancelBlock:(void (^)())onCancelBlock
{
    objc_setAssociatedObject(self, (__bridge const void *)CANCEL_BLOCK_KEY, [onCancelBlock copy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (BFTask*)cancelTask
{
    BoltsExtras_CancelationBlock cancelBlock = objc_getAssociatedObject(self, (__bridge const void *)CANCEL_BLOCK_KEY);
    ;
    // execute the block BEFORE you execute 'super', since that will cause any continuations to occur.
    // we want the cancel block to execute BEFORE any tasks that get triggered by this task completing.
    if ((cancelBlock != NULL) && !self.isCompleted) {
        cancelBlock();
        objc_setAssociatedObject(self, (__bridge const void *)CANCEL_BLOCK_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self trySetCancelled];
    
    return self;
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
