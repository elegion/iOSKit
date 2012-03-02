//
//  AppDelegate.h
//  iOSKitExample
//
//  Created by Yarik Smirnov on 3/3/12.
//  Copyright (c) 2012 e-legion ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iOSKit/iOSKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
