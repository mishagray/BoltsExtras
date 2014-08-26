//
//  NSFileManager+Bolts.h
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bolts.h"

@interface NSFileManager (Bolts)

+ (BFExecutor*) defaultExecutor;

- (BFTask*)removeItemAtURL:(NSURL *)path;


@end
