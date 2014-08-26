//
//  BFTaskItem.h
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bolts.h"

typedef id(^BFTaskItemActionBlock)();

@interface BFTaskItem : NSObject

@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) BFTaskItemActionBlock action;

+(id)itemWithLabel:(NSString *)inLabel andTaskAction:(BFTaskItemActionBlock)action;

@end
