//
//  ELBarButton.m
//  iOSKit
//
//  Created by Yarik Smirnov on 2/14/12.
//  Copyright (c) 2012 e-Legion ltd. All rights reserved.
//

#import "ELBarButton.h"
#import "ELUtils.h"
#import "YSDrawingKit.h"

@interface ELBarButton ()

- (void)animateAlpha:(CGFloat)alpha withRemove:(BOOL)remove;

@end

@implementation ELBarButton
@synthesize holder = _holder;
@synthesize selfOffset = _selfOffset;
@synthesize mode;

- (id)initWithImage:(UIImage *)image asBackground:(BOOL)background andHolder:(id)holder {
    self = [super initWithFrame:YSRectMakeFromSize(30, 30)];
    if (self) {
        _holder = holder;
        [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = ELFontGetHelveticaNeue(12, ELFontStyleBold);
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
        if (background) {
            [self setBackgroundImage:image forState:UIControlStateNormal];
        } else {
            [self setImage:image forState:UIControlStateNormal];
        }
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)show {
    [self animateAlpha:1.0 withRemove:NO];
}

- (void)hideWithRemove:(BOOL)remove {
    [self animateAlpha:0.0 withRemove:remove];
}

- (void)animateAlpha:(CGFloat)alpha withRemove:(BOOL)remove {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent animations:^{ 
        
        if (!remove) {
            self.alpha = alpha;
        } else {
            [self removeFromSuperview];
        }

    } completion:NULL];
}

@end
