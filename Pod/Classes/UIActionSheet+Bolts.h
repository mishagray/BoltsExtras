//
//  UIActionSheet+Bolts.h
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFTaskItem.h"

@interface UIActionSheet (Bolts) <UIActionSheetDelegate>

- (id)initWithTitle:(NSString *)inTitle
          cancelButtonItem:(BFTaskItem *)inCancelButtonItem
     destructiveButtonItem:(BFTaskItem *)inDestructiveItem
          otherButtonArray:(NSArray*)inOtherButtonArray;


- (BFTask*)showTask;

@end
