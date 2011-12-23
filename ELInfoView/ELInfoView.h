//
//  ELInfoView.h
//  iOSKit e-Legion
//
//  Simple analogue UIAlertView to show user some info
//  But more tiny and beautiful
//
//  Created by Yarik Smirnov on 12/12/11.
//  Copyright 2011 e-Legion ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELInfoView : UIWindow {
    UILabel *_title;
    UILabel *_message;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)showWithInterval:(NSTimeInterval)showTime;

- (void)show;

@end
