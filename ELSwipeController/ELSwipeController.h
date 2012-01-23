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
@protected
    UIScrollView    *_controllersContainer;
    NSMutableArray  *_controllers;
    ELSwipeBar      *_swipeBar;
    id              _swipeDelegate;
}
@property (nonatomic, retain) UIColor *titleColor; //Text color of controllers titles
@property (nonatomic, retain) UIColor *shadowColor; //Shadow color of the controllers titles
@property (nonatomic, assign) CGFloat *fontSize; // Font size of controllers titles;
@property (nonatomic, retain) UIColor *titleBackgroundColor; // Controllers titles background;
@property (nonatomic, retain) UIColor *backgroundColor; // Use this color if controllers views is transparrent
@property (nonatomic, retain) UIImage *titlesBackgroundImage; // 1 pixel width;

- (id)initWithControllersStack:(NSArray *)controllers;

@end

