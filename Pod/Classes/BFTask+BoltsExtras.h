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

typedef id(^SimpleBFContinuationBlock)();


typedef id(^BoltsExtras_RepeatingTimerBlock)(BOOL * STOP);

@interface BECompletionToken : BFTaskCompletionSource

+ (instancetype) token;

@end

@interface BFTask (BoltsExtras)



/*!
 Returns a task that can only be cancelled.  (it can't be completed any other way).
 you have to call cancelationToken to cancel this task.
 @param token cancellationToken required to cancel this task.
 */
+ (instancetype)taskWithCompletionToken:(BECompletionToken*)token;


/*!
 Returns a task that will be completed a certain amount of time in the future.
 this task will 'exit' immediately if the 'cancelTask' operation is executed.
 @param millis The approximate number of milliseconds to wait before the
 task will be finished (with result == nil).
 */
+ (instancetype)taskWithDelay:(int)millis completionToken:(BECompletionToken*)token;


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
+ (instancetype)taskWithRepeatingTimeInterval:(NSTimeInterval)ti
                           withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                            completionToken:(BECompletionToken*)completionToken;


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
+ (instancetype)taskWithRepeatingTimeInterval:(NSTimeInterval)ti
                                     withRepeatingBlock:(id (^)(BOOL * STOP))repeatingTimerBlock
                                      completionToken:(BECompletionToken*)completionToken
                                           withExecutor:(BFExecutor *)executor;


- (BOOL)isSuccessful;


/*!
 simple notatation when you don't need to look at the results of the task.
 Can make the code look smaller (especially when using swift
 */
- (instancetype)continueWith:(SimpleBFContinuationBlock)block;

/*!
 simple notatation when you don't need to look at the results of the task.
 Can make the code look smaller (especially when using swift
 */
- (instancetype)continueWithSuccess:(SimpleBFContinuationBlock)block;

/*!
 simple notatation when you don't need to look at the results of the task.
 Can make the code look smaller (especially when using swift
 */
- (instancetype)continueWithExecutor:(BFExecutor *)executor
                           with:(SimpleBFContinuationBlock)block;


/*!
 simple notatation when you don't need to look at the results of the task.
 Can make the code look smaller (especially when using swift
 */
- (instancetype)continueWithExecutor:(BFExecutor *)executor
                    withSuccess:(SimpleBFContinuationBlock)block;



@end


@interface BFTaskCompletionSource (BoltsExtras)

- (void)setCompletionValuesWithTask:(BFTask*)task;
- (BOOL)trySetCompletionValuesWithTask:(BFTask*)task;


@end





