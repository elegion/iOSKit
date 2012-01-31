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

#import "ELInfoView.h"
#import "YSDrawingKit.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kDefaultInfoViewWidth = 260.0;
static CGFloat const kDefaultTextMargin = 10.0;
//Interval of transition from one alpha value to another
static NSTimeInterval const kDefaultTransitionInterval = 0.5;
//Interval before view wil start hide animaion
static NSTimeInterval const kDefaultHideAnimationDelay = 5.0;

static CGFloat const kDefaultlLabelsBreak = 5.0;

static CGFloat const kVisibleAlphaValue = 1.0;
static CGFloat const kHideAlphaValue = 0.0;

@interface ELInfoView (Internal)

- (void)animateAlphaToValue:(CGFloat)alpha withDelay:(NSTimeInterval)interval;
- (void)dismissFromScreen;
- (void)dismiss;

@end

@implementation ELInfoView
@synthesize delegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    if (!title && !message) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        UIFont *helveticaNeueTitle = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        UIFont *helveticaNeueMessage = [UIFont fontWithName:@"HelveticaNeue" size:16];
        CGSize sizeOfTitle = [title sizeWithFont:helveticaNeueTitle constrainedToSize:CGSizeMake(kDefaultInfoViewWidth - 2*kDefaultTextMargin, 10000) lineBreakMode:UILineBreakModeTailTruncation];
        CGSize sizeOfMessage = [message sizeWithFont:helveticaNeueMessage constrainedToSize:CGSizeMake(kDefaultInfoViewWidth - 2*kDefaultTextMargin, 10000) lineBreakMode:UILineBreakModeTailTruncation];
        self.opaque = NO;
        self.bounds = CGRectMake(0, 0, kDefaultInfoViewWidth, sizeOfTitle.height + sizeOfMessage.height + ((title && message ? kDefaultlLabelsBreak : 0.0)) + 2*kDefaultTextMargin);
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2);
        
        CGRect textRect = CGRectInset(self.bounds, kDefaultTextMargin, kDefaultTextMargin);
        
        if (title) {
            CGRect titleRect = YSRectSetHeight(textRect, sizeOfTitle.height);
            _title = [[UILabel alloc] initWithFrame:titleRect];
            _title.backgroundColor = [UIColor clearColor];
            _title.font = helveticaNeueTitle;
            _title.textColor = [UIColor whiteColor];
            _title.textAlignment = UITextAlignmentCenter;
            _title.numberOfLines = 10;
            _title.text = title;
            [self addSubview:_title];
            [_title release];
        }
        if (message) {
            _message = [[UILabel alloc] initWithFrame:CGRectMake(textRect.origin.x, textRect.origin.y + sizeOfTitle.height + (title ? kDefaultlLabelsBreak : 0.0), textRect.size.width, sizeOfMessage.height)];
            _message.backgroundColor = [UIColor clearColor];
            _message.font = helveticaNeueMessage;
            _message.textColor = [UIColor whiteColor];
            _message.textAlignment = UITextAlignmentCenter;
            _message.numberOfLines = 10;
            _message.text = message;
            [self addSubview:_message];
            [_message release];
        }
        self.alpha = 0;
        self.userInteractionEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(dismissFromScreen) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];
	[super dealloc];
}

@end
