//
//  ELPanel.m
//  Ginza
//
//  Created by Yarik Smirnov on 1/31/12.
//  Copyright (c) 2012 e-Legion ltd. All rights reserved.
//

#import "ELPanel.h"
#import "YSDrawingKit.h"

//Interval of transition from one alpha value to another
static NSTimeInterval const kDefaultTransitionInterval = 0.25;
//Interval before view wil start hide animaion
static NSTimeInterval const kDefaultHideAnimationDelay = 5.0;


static CGFloat const kVisibleAlphaValue = 1.0;
static CGFloat const kHideAlphaValue = 0.0;

@interface ELPanel (Internal)

- (void)animateAlphaToValue:(CGFloat)alpha withDelay:(NSTimeInterval)interval;
- (void)dismissFromScreen;

@end

@implementation ELPanel
@synthesize backgroundColor = _backgroundColor;
@synthesize delegate = __delegate;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;

- (id)init {
    self = [super init];
    if (self) {
        self.opaque = NO;
        _shadowOffset = CGSizeMake(1, 1);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();	
    
    CGContextClearRect(context, rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextSetLineWidth(context, 5.0);
    YSPathAddRoundedStrechedRect(path, 5.0, CGRectInset(rect, 5, 5));
    CGContextAddPath(context, path);
    
    CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, _shadowOffset, 3.0, _shadowColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHidden:YES animated:YES];
    if ([self.delegate respondsToSelector:@selector(onPanelTouched)]) {
        [self.delegate performSelector:@selector(onPanelTouched)];
    }
}

- (void)dismissFromScreen {
    [self removeFromSuperview];
}


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [self animateAlphaToValue:!hidden withDelay:0];
    } else {
        self.alpha = !hidden;
    }
}


- (void)showForTime:(NSTimeInterval)interval {
    _autohideStyle = YES;
    [self animateAlphaToValue:kVisibleAlphaValue withDelay:interval];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([finished boolValue] && _autohideStyle) {
        if (self.alpha != 0) {
            [self animateAlphaToValue:kHideAlphaValue withDelay:*((NSTimeInterval *) context)];
        } else {
            [self dismissFromScreen];
        }
    }
}

- (void)animateAlphaToValue:(CGFloat)alpha withDelay:(NSTimeInterval)interval {
    if ([UIView respondsToSelector:@selector(animateWithDuration:delay:options:animations:completion:)]) {
        [UIView animateWithDuration:kDefaultTransitionInterval delay:(alpha != 0 ? 0.0 : interval) options: UIViewAnimationOptionCurveLinear | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.alpha = alpha;
        } completion:^(BOOL finished) {
            [self animationDidStop:nil finished:[NSNumber numberWithBool:finished] context:(NSTimeInterval *)&interval];
        }];
    } else {
        [UIView beginAnimations:@"transition" context:&interval];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:kDefaultTransitionInterval];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
        self.alpha = alpha;
        
        [UIView commitAnimations];
    }
}


@end
