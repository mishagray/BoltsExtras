//
//  NSFileManager+BoltsExtras.h
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


#import <Foundation/Foundation.h>

@class BFExecutor;
@class BFTask;

@interface NSFileManager (BoltsExtras)

// Lots of light weigth NSFileManager tasks that will keep NSFileManager operations out of your main queue!
//
// by default NSFileManager will dispatch operations to DISPATCH_QUEUE_PRIORITY_DEFAULT
// Feel free to change via [NSFIleManager setDefaultExecutor:].
//

+ (BFExecutor*) defaultExecutor;
+ (void) setDefaultExecutor:(BFExecutor*)executor;



- (BFTask*)removeItemAtURL:(NSURL *)path;

- (BFTask*)contentsOfDirectoryAtURL:(NSURL *)url
         includingPropertiesForKeys:(NSArray *)keys
                            options:(NSDirectoryEnumerationOptions)mask;


// returns 1 if file exists at path,  2 if directoy exists at path. nil if no file exists;
+ (BFTask*)checkIfFileOrDirectoryExistsAtPath:(NSString *)path;
- (BFTask*)checkIfFileOrDirectoryExistsAtPath:(NSString *)path;
                                  

// OR Overide the Executor if you want!

- (BFTask*)removeItemAtURL:(NSURL *)path
              withExecutor:(BFExecutor*)executor;

- (BFTask*)contentsOfDirectoryAtURL:(NSURL *)url
         includingPropertiesForKeys:(NSArray *)keys
                            options:(NSDirectoryEnumerationOptions)mask
                       withExecutor:(BFExecutor*)executor;


+ (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl;
+ (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl withExecutor:(BFExecutor*)executor;
- (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl;
- (BFTask*)recursiveSizeForDirectoryAt:(NSURL*)directoryUrl withExecutor:(BFExecutor*)executor;


+ (BFTask*)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
- (BFTask*)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
- (BFTask*)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes withExecutor:(BFExecutor *)executor;

+ (BFTask*)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
- (BFTask*)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes;
- (BFTask*)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes withExecutor:(BFExecutor *)executor;





@end
