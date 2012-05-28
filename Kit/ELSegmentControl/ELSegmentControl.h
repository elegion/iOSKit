//
//  ELSegmentControl.h
//  iOSKit
//
//  Created by Yarik Smirnov on 2/13/12.
//  Copyright (c) 2012 e-Legion ltd. All rights reserved.
//



@interface ELSegmentControl : UIControl {
@private
    NSMutableArray                 *_items;
    
    UIButton                *_leftButton;
    UIButton                *_rightButton;
    
    UIImage                 *_leftNormal;
    UIImage                 *_rightNormal;
    UIImage                 *_leftActive;
    UIImage                 *_rightActive;
}

@property(nonatomic, assign) NSInteger selectedSegmentIndex;
@property(nonatomic, retain) UIFont *titleFont;
@property(nonatomic, retain) UIColor *titleColor;
@property(nonatomic, retain) UIColor *titleShadow;
@property(nonatomic, assign) CGSize shadowOffset;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSInteger)segmentIndex forState:(UIControlState)state;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSInteger)segmentIndex;

@end
