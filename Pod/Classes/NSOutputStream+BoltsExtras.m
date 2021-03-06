//
//  NSOutputStream+BoltsExtras.m
//  DataRecorder
//
//  Created by Michael Gray on 8/28/14.
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

#import "NSOutputStream+BoltsExtras.h"
#import "Bolts.h"

@implementation NSOutputStream (BoltsExtras)


- (BFTask*)writeString:(NSString*)string
         usingEncoding:(NSStringEncoding)encoding
               options:(NSStringEncodingConversionOptions)options;
{
    
    return [self writeString:string usingEncoding:encoding options:options withExecutor:[BFExecutor defaultExecutor]];
}

- (BFTask*)writeBuffer:(const uint8_t *)buffer
             maxLength:(NSUInteger)len
{
    return [self writeBuffer:buffer maxLength:len withExecutor:[BFExecutor defaultExecutor]];
}

- (BFTask*)writeBuffer:(const uint8_t *)buffer
             maxLength:(NSUInteger)len
          withExecutor:(BFExecutor*)executor
{
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        NSInteger bytesWritten = [self write:buffer maxLength:len];
        
        if (self.streamError) {
            [tcs trySetError:self.streamError];
        }
        else {
            [tcs trySetResult:@(bytesWritten)];
        }
    }];
    return tcs.task;
}


- (BFTask*)writeString:(NSString*)string
         usingEncoding:(NSStringEncoding)encoding
               options:(NSStringEncodingConversionOptions)options
          withExecutor:(BFExecutor*)executor {
    
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        
        int8_t buffer[1024];
        NSRange rangeToWrite = NSMakeRange(0, string.length);
        NSInteger bytesWritten = 0;
        
        BOOL done = false;
        while (!done) {
            NSUInteger bytesUsed;
            NSRange nextRange;
            if ([string getBytes:buffer
                       maxLength:sizeof(buffer)
                      usedLength:&bytesUsed
                        encoding:encoding
                         options:options
                           range:rangeToWrite
                  remainingRange:&nextRange]) {
                bytesWritten += [self write:(uint8_t *)buffer maxLength:bytesUsed];
                rangeToWrite = nextRange;
                done = (bytesUsed < sizeof(buffer));
                if (self.streamError != nil) {
                    [tcs trySetError:self.streamError];
                    done = YES;
                }
            } else {
                done = YES;
            }
        }
        [tcs trySetResult:@(bytesWritten)];
    }];
    
    return tcs.task;
}

- (BFTask*)write:(NSData*)data
{
    return [self write:data withExecutor:[BFExecutor defaultExecutor]];
}

- (BFTask*)write:(NSData*)data
          withExecutor:(BFExecutor*)executor {
    
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    [executor execute:^{
        
        NSInteger byesWritten = [self write:data.bytes maxLength:data.length];
        if (self.streamError != nil) {
            [tcs trySetError:self.streamError];
        }
        else {
            [tcs trySetResult:@(byesWritten)];
        }
    }];
    
    return tcs.task;
}

@end
