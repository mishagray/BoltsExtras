//
//  UIAlertView+Bolts.m
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import "UIAlertView+Bolts.h"
#import <objc/runtime.h>
#import "BFTaskItem.h"

static NSString *RI_BUTTON_KEY = @"com.flybyActionItem.UIAlertView.BUTTONS";
static NSString *RI_TASK_COMPLETION_KEY = @"com.flybyActionItem.UIAlertView.TCS";

@implementation UIAlertView (Bolts)

- (id)initWithTitle:(NSString *)inTitle
             message:(NSString *)inMessage
    cancelButtonItem:(BFTaskItem *)cancelButtonItem
    otherButtonArray:(NSArray *)inOtherButtonArray {
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

        BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
        objc_setAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY, tcs,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (BFTask *)showTask {
    BFTaskCompletionSource *tcs =
        objc_getAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY);
    ;

    return tcs.task;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BFTaskCompletionSource *tcs =
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


+ (BFTask *)showAlertWithTitle:(NSString *)title
    message:(NSString *)message
    cancelButtonTitle:(NSString*)cancelButtonLabel
    cancelButtonAction:(id (^)())cancelAction
              otherButtonArray:(NSArray *)otherButtonArray; {

    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              cancelButtonItem:[BFTaskItem itemWithLabel:cancelButtonLabel andTaskAction:cancelAction]
                              otherButtonArray:otherButtonArray];
    [alertView show];
    return alertView.showTask;
}


+ (BFTask *)showAlertWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(NSString *)cancelButtonLabel
            cancelButtonAction:(id (^)())cancelAction
                 okButtonTitle:(NSString *)okButtonLabel
                okButtonAction:(id (^)())okAction {
    
    return [UIAlertView showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonLabel cancelButtonAction:cancelAction otherButtonArray:@[ [BFTaskItem itemWithLabel:okButtonLabel andTaskAction:okAction] ]];
}


@end
