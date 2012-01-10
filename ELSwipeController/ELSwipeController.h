//
//  ELViewController.h
//  ELSwipeController
//
//  Created by Yarik Smirnov on 28.12.11.
//  Copyright (c) 2011 e-legion ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ELSwipeBar;
@interface ELSwipeController : UIViewController {
@private
    UIScrollView    *_controllersContainer;
    NSMutableArray  *_controllers;
    ELSwipeBar      *_swipeBar;
    id              _swipeDelegate;
}

- (id)initWithControllersStack:(NSArray *)controllers;

@end
