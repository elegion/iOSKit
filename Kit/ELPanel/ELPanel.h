//
//  ELPanel.h
//  Ginza
//
//  Created by Yarik Smirnov on 1/31/12.
//  Copyright (c) 2012 e-Legion ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ELPanelDelegate <NSObject>
@optional
- (void)onPanelTouched;

@end

@interface ELPanel : UIView {
@protected
    BOOL                    _autohideStyle;
    NSTimeInterval          _customInteval;
    id<ELPanelDelegate>     _delegate;
}

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) id<ELPanelDelegate> delegate; 

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)showForTime:(NSTimeInterval)interval;

@end
