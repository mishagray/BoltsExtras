//
//  BFTask+DebugQuickLook.m
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
