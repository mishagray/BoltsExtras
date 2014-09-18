//
//  NSFileManager+BoltsExtras.m
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


#import "NSFileManager+BoltsExtras.h"
#import "Bolts.h"

static BFExecutor *s_executorForFileManager = nil;

@implementation NSFileManager (BoltsExtras)

+ (BFExecutor*) defaultExecutor
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (s_executorForFileManager == nil) {
            s_executorForFileManager = [BFExecutor executorWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        }
    });
    return s_executorForFileManager;
}
+ (NSFileManager*)defaultManagerOrCreate
{
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    if (defaultManager == nil) {
        defaultManager = [[NSFileManager alloc] init];
    }
    return defaultManager;
}


+ (void) setDefaultExecutor:(BFExecutor*)executor
{
    s_executorForFileManager = executor;
}

- (BFTask*)removeItemAtURL:(NSURL *)path
{
    return [self removeItemAtURL:path withExecutor:[NSFileManager defaultExecutor]];
}
- (BFTask*)contentsOfDirectoryAtURL:(NSURL *)url
         includingPropertiesForKeys:(NSArray *)keys
                            options:(NSDirectoryEnumerationOptions)mask
{
    return [self contentsOfDirectoryAtURL:url includingPropertiesForKeys:keys options:mask withExecutor:[NSFileManager defaultExecutor]];
}


+ (BFTask*)checkIfFileOrDirectoryExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManagerOrCreate] checkIfFileOrDirectoryExistsAtPath:path];
}

- (BFTask*)checkIfFileOrDirectoryExistsAtPath:(NSString *)path
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [[NSFileManager defaultExecutor] execute:^{
        
        BOOL isDirectory = NO;
        BOOL exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
        
        if (isDirectory) {
            [tcs setResult:@(2)];
        }
        else if (exists) {
            [tcs setResult:@(1)];
        }
        else {
            [tcs setResult:nil];
        }
    }];
    
    return tcs.task;
}

+ (BFTask*)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes
{
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:YES];
    return [[NSFileManager defaultManagerOrCreate] createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes withExecutor:[NSFileManager defaultExecutor]];
    
}
- (BFTask*)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes
{
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:YES];
    return [self createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes withExecutor:[NSFileManager defaultExecutor]];
    
}
- (BFTask*)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes withExecutor:(BFExecutor *)executor
{
    NSURL * url = [NSURL fileURLWithPath:path isDirectory:YES];
    return [self createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes withExecutor:executor];
}



+ (BFTask*)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes
{
    return [[NSFileManager defaultManagerOrCreate] createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes withExecutor:[NSFileManager defaultExecutor]];
}
- (BFTask*)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
{
    return [self createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes withExecutor:[NSFileManager defaultExecutor]];
    
}

- (BFTask*)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes withExecutor:(BFExecutor *)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        NSError * error = nil;
        
        if (![self createDirectoryAtURL:url withIntermediateDirectories:createIntermediates attributes:attributes error:&error]) {
            [tcs trySetError:error];
        }
        else {
            [tcs trySetResult:url];
        }
    }];
    return tcs.task;
}


- (BFTask*)removeItemAtURL:(NSURL *)path withExecutor:(BFExecutor *)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        NSError * error = nil;
 
        [self removeItemAtURL:path error:&error];
        if (error != nil) {
            tcs.error = error;
        }
        else {
            [tcs trySetResult:nil];
        }
    }];
    
    return tcs.task;
}

- (BFTask*)contentsOfDirectoryAtURL:(NSURL *)url
         includingPropertiesForKeys:(NSArray *)keys
                            options:(NSDirectoryEnumerationOptions)mask
                       withExecutor:(BFExecutor*)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        NSError * error = nil;
        
        NSArray * contents = [self contentsOfDirectoryAtURL:url includingPropertiesForKeys:keys options:mask error:&error];
        if (error != nil) {
            tcs.error = error;
        }
        else {
            [tcs trySetResult:contents];
        }
    }];
    return tcs.task;
   
}
+ (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl
{
    return [[self defaultManagerOrCreate] recursiveSizeForDirectoryAt:directoryUrl withExecutor:[self defaultExecutor]];
}
+ (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl withExecutor:(BFExecutor*)executor
{
    return [[self defaultManagerOrCreate] recursiveSizeForDirectoryAt:directoryUrl withExecutor:executor];
}

- (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl
{
    return [self recursiveSizeForDirectoryAt:directoryUrl withExecutor:[NSFileManager defaultExecutor]];
}

- (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl withExecutor:(BFExecutor*)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    
    [executor execute:^{
        NSDirectoryEnumerator *de = [self enumeratorAtURL:directoryUrl includingPropertiesForKeys:@[NSURLFileSizeKey] options:0 errorHandler:^BOOL(NSURL *url, NSError *err) {
            [tcs trySetError:err];
            return NO;
        }];
        
        NSURL * fileUrl;
        NSInteger directorySize = 0;
        
        while ((fileUrl = [de nextObject]) && !tcs.task.isCompleted) {
            // make the filename |f| a fully qualifed filename
            
            NSNumber * fileSize = nil;
            NSError * error = nil;
            if ([fileUrl getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
                directorySize += [fileSize integerValue];
            }
            else {
                [tcs trySetError:error];
            }
        }
        
        [tcs trySetResult:@(directorySize)];
    }];
    
    return tcs.task;

}

+ (BFTask *)attributesOfItemAtPath:(NSString *)path
{
    return [[self defaultManagerOrCreate] attributesOfItemAtPath:path withExecutor:[NSFileManager defaultExecutor]];
}


- (BFTask *)attributesOfItemAtPath:(NSString *)path
{
    return [self attributesOfItemAtPath:path withExecutor:[NSFileManager defaultExecutor]];
}


- (BFTask *)attributesOfItemAtPath:(NSString *)path withExecutor:(BFExecutor *)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    
    [executor execute:^{
        
        NSError * error = nil;
        
        NSDictionary * attributes = [self attributesOfItemAtPath:path error:&error];
        
        if (error) {
            [tcs trySetError:error];
        }
        else {
            [tcs trySetResult:attributes];
        }
    }];
    
    return tcs.task;
    
}




@end