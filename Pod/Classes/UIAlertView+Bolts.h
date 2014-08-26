//
//  UIAlertView+Bolts.h
//  DataRecorder
//
//  Created by Michael Gray on 8/25/14.
//  Copyright (c) 2014 Flyby Media LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bolts.h"

@interface UIAlertView (Bolts)

+(BFTask*)showAlertWithTitle:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString*)cancelButtonLabel
     cancelButtonAction:(id (^)())cancelAction
       otherButtonArray:(NSArray *)otherButtonArray;


+(BFTask*)showAlertWithTitle:(NSString *)title
                message:(NSString *)message
      cancelButtonTitle:(NSString*)cancelButtonLabel
     cancelButtonAction:(id (^)())cancelAction
          okButtonTitle:(NSString*)okButtonLabel
         okButtonAction:(id (^)())okAction;

- (BFTask*)showTask;

@end
