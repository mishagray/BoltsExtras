//
//  BFTask+BoltsExtras.h
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

#import "Bolts.h"

typedef id(^BoltsExtras_RepeatingTimerBlock)(BOOL * STOP);


@interface BFTask (BoltsExtras)

/*!
 will cancel a task, and cause it's continutions to execute.
 should really only be used with cancelableTaskWithDelay or cancelableTaskWithRepeatingTimeInterval
 it WILL cause any BFTask to cancel, but some tasks don't like to be suddenly cancelled and might throw exceptions.
 returns 'self' so you can do things like.
 
 BFTask * longRunningTask = [BFTask cancelableTaskWithDelay:10000000];
 [[longRunningTask cancelTask] 
         continueWithBlock:^id(BFTask *task) {  if (task.completed) return @"I didn't cancel it fast enough" 
                                                else return @"task was cancelled" }];
 

:
 */
- (BFTask*)cancelTask;


/*!
 will execute a block BEFORE other tasks completion blocks are called.  Can help implement logic to "clean up" a BFTask when a cancellation is requested via 'cancelTask']
 there is no return value, since the task's completion value will automatically be set to 'cancelled'.
 */
- (void)setOnCancelBlock:(void (^)())onCancelBlock;



/*!
 Returns a task that will be completed a certain amount of time in the future.
 this task will 'exit' immediately if the 'cancelTask' operation is executed.
 @param millis The approximate number of milliseconds to wait before the
 task will be finished (with result == nil).
 */
+ (instancetype)cancelableTaskWithDelay:(int)millis;


/*!
 Returns a BFTask that uses a TMTimer that will execute a block over and over.
 the block will get called repeatedly until *STOP is set to YES or the 'cancelTask' is requested by the owner.
 if *STOP is set to YES, than the return value of block will be the return value of the BFTask.
 the return value of blocks where *STOP = no are ignored.
 the onCancelBlock is executed if the [BFTask cancelTask] is called. This can be set to NULL.
 this version uses [BFExecutor immediateExecutuor] - blocks will execute directly in the TMTimer's callback thread.
 
 @param ti the time interval between block executions.
 @param repeatingTimerBlock block executes every 'ti' time interval, until either *STOP is set to YES, or the 'cancelTask' method is called.
 @param onCancelBlock executes if the [task cancelTask] method is called.  It may be NULL
 
 */
+ (instancetype)cancelableTaskWithRepeatingTimeInterval:(NSTimeInterval)ti
                                     withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                                                onCancelBlock:(void (^)())onCancelBlock;


/*!
 Returns a BFTask that uses a TMTimer that will execute a block over and over.
 the block will get called repeatedly until *STOP is set to YES or the 'cancelTask' is requested by the owner.
 if *STOP is set to YES, than the return value of block will be the return value of the BFTask.
 the return value of blocks where *STOP = no are ignored.
 the onCancelBlock is executed if the [BFTask cancelTask] is called. This can be set to NULL.
 this version uses [BFExecutor immediateExecutuor] - blocks will execute directly in the TMTimer's callback thread.
 
 @param ti the time interval between block executions.
 @param repeatingTimerBlock block executes every 'ti' time interval, until either *STOP is set to YES, or the 'cancelTask' method is called.
 @param onCancelBlock executes if the [task cancelTask] method is called.  It may be NULL
 @param executor will execute all blocks using the executor supplied.
 
 */
+ (instancetype)cancelableTaskWithRepeatingTimeInterval:(NSTimeInterval)ti
                                     withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                                          onCancelBlock:(void (^)())onCancelBlock
                                           withExecutor:(BFExecutor *)executor;

@end



