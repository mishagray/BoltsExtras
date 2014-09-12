//
//  NSJSONSerialization+BoltsExtra.h
//  Pods
//
//  Created by Michael Gray on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@class BFTask;
@class BFExecutor;

@interface NSJSONSerialization (BoltsExtra)

+ (BFTask*)writeJSONObject:(id)object toURL:(NSURL*)url options:(NSJSONWritingOptions)options;
+ (BFTask*)writeJSONObject:(id)object toURL:(NSURL*)url options:(NSJSONWritingOptions)options withExecutor:(BFExecutor*)executor;


+ (BFTask*)JSONObjectWithUrl:(NSURL*)url options:(NSJSONReadingOptions)options;
+ (BFTask*)JSONObjectWithUrl:(NSURL*)url options:(NSJSONReadingOptions)options withExecutor:(BFExecutor*)executor;


@end
