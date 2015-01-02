//
//  UIAlertView+Bolts.m
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


#import "BoltsExtras.h"
#import <objc/runtime.h>
#import "BFTaskItem.h"

static NSString *RI_BUTTON_KEY = @"com.pushleaf.BoltsExtras.UIAlertView.BUTTONS";
static NSString *RI_TASK_COMPLETION_KEY = @"com.pushleaf.BoltsExtras.UIAlertView.TCS";

@implementation UIAlertView (BoltsExtras)


- (id)initWithTaskWithTitle:(NSString *)inTitle
             message:(NSString *)inMessage
    cancelButtonItem:(BFTaskItem *)cancelButtonItem
    otherButtonArray:(NSArray *)inOtherButtonArray
    completionToken:(BECompletionToken*)token {

    if ((self = [self initWithTitle:inTitle
                            message:inMessage
                           delegate:self
                  cancelButtonTitle:cancelButtonItem.label
                  otherButtonTitles:nil])) {
        NSMutableArray *buttonsArray;
        if (inOtherButtonArray == nil)
            buttonsArray = [NSMutableArray arrayWithCapacity:2];
        else
            buttonsArray = [inOtherButtonArray mutableCopy];

        for (BFTaskItem *item in buttonsArray) {
            [self addButtonWithTitle:item.label];
        }

        if (cancelButtonItem) [buttonsArray insertObject:cancelButtonItem atIndex:0];

        objc_setAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY, buttonsArray,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        __weak UIAlertView * weakSelf = self;
        
        
        [token.task continueWithBlock:^id(BFTask *task) {
            if (task.cancelled) {
                [weakSelf dismissWithClickedButtonIndex:weakSelf.cancelButtonIndex animated:YES];
            }
            return task.result;
        }];
        objc_setAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY, token,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (BFTask *)showTask {
    BECompletionToken *tcs =
        objc_getAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY);
    ;

    return tcs.task;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BECompletionToken *tcs =
        objc_getAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY);
    ;

    // If the button index is -1 it means we were dismissed with no selection
    if (buttonIndex >= 0) {
        NSArray *buttonsArray =
            objc_getAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY);
        BFTaskItem *item = buttonsArray[buttonIndex];
        if (item.action) {
            [tcs trySetResult:item.action()];
        } else {
            [tcs trySetResult:nil];
        }
    } else {
        [tcs trySetCancelled];
    }

    objc_setAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY, nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BFTask *)showAlertTaskWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString*)cancelButtonLabel
            cancelButtonAction:(id (^)())cancelAction
              otherButtonArray:(NSArray *)otherButtonArray
{
    return [self showAlertTaskWithTitle:title message:message cancelButtonTitle:cancelButtonLabel cancelButtonAction:cancelAction otherButtonArray:otherButtonArray completionToken:[BECompletionToken token]];
}


+ (BFTask *)showAlertTaskWithTitleTask:(NSString *)title
    message:(NSString *)message
    cancelButtonTitle:(NSString*)cancelButtonLabel
    cancelButtonAction:(id (^)())cancelAction
     otherButtonArray:(NSArray *)otherButtonArray
        completionToken:(BECompletionToken *)token
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [[BFExecutor mainThreadExecutor] execute:^{

        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTaskWithTitle:title
                                  message:message
                                  cancelButtonItem:[BFTaskItem itemWithLabel:cancelButtonLabel andTaskAction:cancelAction]
                                  otherButtonArray:otherButtonArray completionToken:token];
                                  
        [alertView show];
        [[alertView showTask] continueWithBlock:^id(BFTask *task) {
            [tcs setCompletionValuesWithTask:task];
            return task.result;
        }];
    }];
    return tcs.task;
}


+ (BFTask *)showAlertTaskWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonLabel
            cancelButtonAction:(id (^)())cancelAction
                 okButtonTitle:(NSString *)okButtonLabel
                okButtonAction:(id (^)())okAction {
    
    return [UIAlertView showAlertTaskWithTitle:title message:message cancelButtonTitle:cancelButtonLabel cancelButtonAction:cancelAction otherButtonArray:@[ [BFTaskItem itemWithLabel:okButtonLabel andTaskAction:okAction] ]];
}

+ (BFTask *)showAlertTaskWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonLabel
            cancelButtonAction:(id (^)())cancelAction
                 okButtonTitle:(NSString *)okButtonLabel
                okButtonAction:(id (^)())okAction
                completionToken:(BECompletionToken *)token {
        return [UIAlertView showAlertTaskWithTitle:title message:message cancelButtonTitle:cancelButtonLabel cancelButtonAction:cancelAction otherButtonArray:@[ [BFTaskItem itemWithLabel:okButtonLabel andTaskAction:okAction] ] completionToken:token];
}


@end
