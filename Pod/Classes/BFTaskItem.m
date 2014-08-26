//
//  BFTaskItem.m
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import "BFTaskItem.h"

@implementation BFTaskItem

+(id)item
{
    return [self new];
}

+(id)itemWithLabel:(NSString *)inLabel andTaskAction:(BFTaskItemActionBlock)action;
{
    BFTaskItem * newItem = [BFTaskItem item];
    newItem.label = inLabel;
    newItem.action = action;
    return newItem;
}

@end
