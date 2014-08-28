//
//  UIActionSheet+Bolts.m
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


#import "UIActionSheet+BoltsExtras.h"
#include "BFTaskItem.h"
#import <objc/runtime.h>

static NSString *RI_BUTTON_KEY = @"com.flybyActionItem.UIActionSheet.BUTTONS";
static NSString *RI_TASK_COMPLETION_KEY = @"com.flybyActionItem.UIActionSheet.TCS";



@implementation UIActionSheet (BoltsExtras)


- (id)initWithTitle:(NSString *)inTitle
   cancelButtonItem:(BFTaskItem *)inCancelButtonItem
destructiveButtonItem:(BFTaskItem *)inDestructiveItem
   otherButtonArray:(NSArray*)inOtherButtonArray;
{
    
    if((self = [self initWithTitle:inTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]))
    {
        NSMutableArray *buttonsArray = nil;
        if (inOtherButtonArray != nil)
            buttonsArray = [inOtherButtonArray mutableCopy];
        else
            buttonsArray = [NSMutableArray arrayWithCapacity:3];
        
        for(BFTaskItem *item in inOtherButtonArray)
        {
            [self addButtonWithTitle:item.label];
        }
        
        if(inDestructiveItem)
        {
            [buttonsArray addObject:inDestructiveItem];
            NSInteger destIndex = [self addButtonWithTitle:inDestructiveItem.label];
            [self setDestructiveButtonIndex:destIndex];
        }
        if(inCancelButtonItem)
        {
            [buttonsArray addObject:inCancelButtonItem];
            NSInteger cancelIndex = [self addButtonWithTitle:inCancelButtonItem.label];
            [self setCancelButtonIndex:cancelIndex];
        }
        
        objc_setAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        BFTaskCompletionSource * tcs = [BFTaskCompletionSource taskCompletionSource];
        objc_setAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY, tcs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
    
}

- (NSInteger)addButtonItem:(BFTaskItem *)item
{
    NSMutableArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY);
    
    NSInteger buttonIndex = [self addButtonWithTitle:item.label];
    [buttonsArray addObject:item];
    
    return buttonIndex;
}
- (NSInteger)addButtonWithLabel:(NSString *)inLabel andAction:(BFTaskItemActionBlock)inAction
{
    return [self addButtonItem:[BFTaskItem itemWithLabel:inLabel andTaskAction:inAction]];
}


- (BFTask*)showTask
{
    BFTaskCompletionSource * tcs = objc_getAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY);;
    
    return tcs.task;
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    BFTaskCompletionSource * tcs = objc_getAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY);;

    // Action sheets pass back -1 when they're cleared for some reason other than a button being
    // pressed.
    if (buttonIndex >= 0)
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY);
        BFTaskItem *item = buttonsArray[buttonIndex];
        if(item.action) {
            [tcs setResult:item.action()];
        }
    }
    [tcs trySetResult:nil];
    
    objc_setAssociatedObject(self, (__bridge const void *)RI_BUTTON_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)RI_TASK_COMPLETION_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
