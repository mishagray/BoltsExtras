//
//  NSURL+BoltsExtras.h
//  Pods
//
//  Created by Michael Gray on 9/16/14.
//
//

#import <Foundation/Foundation.h>

@class BFTask;
@class BFExecutor;

@interface NSURL (BoltsExtras)

- (BFTask*)getResourceValueForKey:(NSString *)key;
- (BFTask*)getResourceValueForKey:(NSString *)key withExecutor:(BFExecutor*)executor;

@end
