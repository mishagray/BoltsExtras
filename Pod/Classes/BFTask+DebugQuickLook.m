//
//  BFTask+DebugQuickLook.m
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import "BFTask+DebugQuickLook.h"

@implementation BFTask (DebugQuickLook)

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
