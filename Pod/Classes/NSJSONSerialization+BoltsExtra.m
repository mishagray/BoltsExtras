//
//  NSJSONSerialization+BoltsExtra.m
//  Pods
//
//  Created by Michael Gray on 9/11/14.
//
//

#import "BoltsExtras.h"

@implementation NSJSONSerialization (BoltsExtra)


+ (BFTask*)writeJSONObject:(id)object toURL:(NSURL*)url options:(NSJSONWritingOptions)options
{
    return [self writeJSONObject:object toURL:url options:options withExecutor:[NSFileManager defaultExecutor]];
}

+ (BFTask*)writeJSONObject:(id)object toURL:(NSURL*)url options:(NSJSONWritingOptions)options withExecutor:(BFExecutor*)executor
{
    BFTaskCompletionSource * writing_task = [BFTaskCompletionSource taskCompletionSource];
    
    [executor execute:^{
        NSError * error = nil;
        NSData * jsonText = [NSJSONSerialization dataWithJSONObject:object options:options error:&error];
        
        if (error != nil) {
            [writing_task setError:error];
        }
        else {
        if (![jsonText writeToURL:url options:0 error:&error]) {
                [writing_task setError:error];
            }
            else {
                [writing_task setResult:nil];
            }
        }
    }];
    return writing_task.task;
}

+ (BFTask*)JSONObjectWithUrl:(NSURL*)url options:(NSJSONReadingOptions)options
{
    return [self JSONObjectWithUrl:url options:options withExecutor:[BFExecutor defaultExecutor]];
}


+ (BFTask*)JSONObjectWithUrl:(NSURL*)url options:(NSJSONReadingOptions)options withExecutor:(BFExecutor*)executor
{
    BFTaskCompletionSource * tcs = [BFTaskCompletionSource taskCompletionSource];
    
    [executor execute:^{
       NSError * error = nil;
        
        NSData * data = [NSData dataWithContentsOfURL:url];
        if (data.length > 0) {
            NSObject * object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
            
            if (error != nil) {
                [tcs setError:error];
            }
            else {
                [tcs setResult:object];
            }
        }
        else {
            [tcs setResult:nil];
        }
    }];
    
    return tcs.task;

}

@end
