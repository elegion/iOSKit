//
//  ELViewController.m
//  ELSwipeController
//
//  Created by Yarik Smirnov on 28.12.11.
//  Copyright (c) 2011 e-legion ltd. All rights reserved.
//

#import "ELSwipeController.h"
#import "YSDrawingKit.h"
#import <CoreText/CoreText.h>
#include "math.h"

@interface ELSwipeBar : UIView <UIScrollViewDelegate> {
    NSString    *_leftTitle;
    NSString    *_rightTitle;
    NSString    *_centerTitle;
    CGFloat     _globalScrollShift;
    
    CGColorRef  _textColor;
    CGColorRef  _shadowColor;
    CGColorRef  _backgroundColor;
    
    UIImage     *_backgroundImage;
    
    CGFloat     _fontSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withRight:(NSString *)rTitle center:(NSString *)cTitle left:(NSString *)lTitle;

- (void)setTextColor:(CGColorRef)textColor;

- (void)setShadowColor:(CGColorRef)shadowColor;

- (void)setBackgroundColor:(CGColorRef)backgroundColor;

- (void)setBackgroundImage:(UIImage *)image;

@end


@interface ELSwipeController (Internal) <UIScrollViewDelegate>

- (void)loadControllersViews;

- (UIScrollView *)controllersContainer;

- (ELSwipeBar *)swipeBar;

- (NSArray *)controllers;

- (void)scrollTo:(CGFloat)offset;

@end

@implementation ELSwipeController

@synthesize titleColor = _titleColor;
@synthesize shadowColor = _shadowColor;
@synthesize fontSize = _fontSize;
@synthesize titleBackgroundColor = _titleBackgroundColor;
@synthesize backgroundColor = _backgroundColor;
@synthesize titlesBackgroundImage = _titlesBackgroundImage;
@synthesize hideSwipeBar;

CGFloat     _currentOffset;

- (id)initWithControllersStack:(NSArray *)controllers {
    if (!controllers) {
        NSAssert(controllers, @"Controllers must not be nil.");
        return nil;
    }
    self = [self init];
    if (self) {
        _controllers = [controllers mutableCopy];
    }
    return self;
}

- (id)init {
    self = [super init]; 
    if (self) {
        _controllersContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _controllersContainer.pagingEnabled = YES;
        _controllersContainer.delegate = self;
        _controllersContainer.showsVerticalScrollIndicator = NO;
        _controllersContainer.showsHorizontalScrollIndicator = NO;
        _controllersContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
        
        _swipeBar = [[ELSwipeBar alloc] init];
        _swipeDelegate = _swipeBar;
        self.hideSwipeBar = false;
        
        _currentOffset = 0;
    }
    return self;
}

- (void)setControllers:(NSArray *)controllers {
    for (UIViewController *controller in _controllers) {
        if (controller.view.superview) {
            [controller.view removeFromSuperview];
        }
    }
    [_controllers release];
    _controllers = [controllers mutableCopy];
    
    if ([self isViewLoaded]) {
        [self loadControllersViews];
    }
}

- (UIScrollView *)controllersContainer {
    return _controllersContainer;
}

- (ELSwipeBar *)swipeBar {
    return _swipeBar;
}

- (NSArray *)controllers {
    return _controllers;
}

- (void)loadView {
    [super loadView];
    
    UIScreen *screen = [UIScreen mainScreen];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    CGSize size = CGSizeMake(screen.bounds.size.width, screen.bounds.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.tabBarController.tabBar.frame.size.height - app.statusBarFrame.size.height - CGRectGetHeight(_swipeBar.frame));
    
    CGRect mainViewFrame = CGRectZero;
    
    mainViewFrame = YSRectSetSize(mainViewFrame, size);
    
    _controllersContainer.frame = mainViewFrame;
    
    _controllersContainer.frame = YSRectSetOriginY(_controllersContainer.frame, CGRectGetHeight(_swipeBar.frame));
    
    [self loadControllersViews];
}


- (void)loadControllersViews {
    if ([_controllers count] > 0) {
        
        if (_swipeBar.superview) {
            [_swipeBar removeFromSuperview];
        }
        
        if (!self.hideSwipeBar) {
            [self.view addSubview:_swipeBar];
        }
        
        _controllersContainer.contentSize = CGSizeZero;
        _controllersContainer.contentSize = CGSizeMake(_controllersContainer.frame.size.width * [_controllers count] + 1, CGRectGetHeight(_controllersContainer.frame));
        
        for (int i = 0; i < [_controllers count]; i++) {
            UIViewController *viewController = [_controllers objectAtIndex:i];
            viewController.view.frame = YSRectSetOriginX(viewController.view.frame, CGRectGetWidth(self.view.frame)*i);
            viewController.view.frame = YSRectSetOriginY(viewController.view.frame, 0);
            viewController.view.frame = YSRectSetSize(viewController.view.frame, _controllersContainer.frame.size);
            [_controllersContainer addSubview:viewController.view];
        }
        
        if ([_controllers count] > 1) {
            [self scrollViewDidScroll:_controllersContainer];
        } else {
            _controllersContainer.scrollEnabled = NO;
            [_swipeBar scrollViewDidScroll:_controllersContainer withRight:nil center:[[_controllers lastObject] title] left:nil];
        }
        
        if (!_controllersContainer.superview) {
            [self.view insertSubview:_controllersContainer atIndex:0];
        }
    }
}

- (void)scrollFinished {
    _currentOffset = _controllersContainer.contentOffset.x;
    
    NSUInteger index = floor((_controllersContainer.contentOffset.x - _controllersContainer.frame.size.width / 2) / _controllersContainer.frame.size.width) + 1;
    
    if (_controllersContainer.contentOffset.x >= 0 && _controllersContainer.contentOffset.x <= (_controllersContainer.contentSize.width - CGRectGetWidth(self.view.bounds))) {
        [self scrolledToSection:index];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollFinished];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollFinished];
}

- (void)scrollToController:(NSInteger)index {
    UIViewController *ctrl = [_controllers objectAtIndex:index];
    [self scrollTo:CGRectGetMinX(ctrl.view.frame)];
}

- (void)scrollTo:(CGFloat)offset {
    if (offset >= 0 && offset <= _controllersContainer.contentSize.width - _controllersContainer.frame.size.width) {
        _currentOffset = offset;
        [_controllersContainer setContentOffset:CGPointMake(offset, _controllersContainer.contentOffset.y) animated:YES];
    }
}

- (void)scrollLeft {
    [self scrollTo:_currentOffset-_controllersContainer.frame.size.width];
}

- (void)scrollRight {
    [self scrollTo:_currentOffset+_controllersContainer.frame.size.width];
}

- (void)scrolledToSection:(NSUInteger)sectionIndex {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentController = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    NSInteger index = currentController;

    NSString *left, *right;
    UIViewController* centerController = index < [_controllers count] ? [_controllers objectAtIndex:index]  : nil;
    NSString *center = centerController.title;
    if ([_controllers count] > 2) {
        left = index > 0 ? [[_controllers objectAtIndex:index - 1] title] : [[_controllers lastObject] title];
        right = index <= [_controllers count] - 2 ? [[_controllers objectAtIndex:index + 1] title] : [[_controllers objectAtIndex:0] title];
    } else {
        left = (index == 1) ? [[_controllers objectAtIndex:0] title] : nil;
        right = (index == 0) ? [[_controllers objectAtIndex:1] title] : nil;
    }
    if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= (scrollView.contentSize.width - CGRectGetWidth(self.view.bounds))) {
        [_swipeDelegate scrollViewDidScroll:scrollView withRight:right center:center left:left];
    }
    
    if ([_controllers count] >= 3) {
        if (currentController == [_controllers count] - 1) {
            UIViewController *firstController = [[_controllers objectAtIndex:0] retain];
            
            
            for (UIViewController *viewController in _controllers) {
                viewController.view.frame = YSRectSetOriginX(viewController.view.frame, viewController.view.frame.origin.x - scrollView.frame.size.width);
            }
            
            firstController.view.frame = YSRectSetOriginX(firstController.view.frame, scrollView.frame.size.width * ([_controllers count] - 1));
            
            [_controllers removeObjectAtIndex:0];
            [_controllers addObject:firstController];
            
            [firstController release];
            
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - scrollView.frame.size.width, scrollView.contentOffset.y);
            _currentOffset -= scrollView.frame.size.width;
        } else if (currentController == 0) {
            
            UIViewController *lastController = [[_controllers lastObject] retain];
            
            
            for (UIViewController *viewController in _controllers) {
                viewController.view.frame = YSRectSetOriginX(viewController.view.frame, viewController.view.frame.origin.x + scrollView.frame.size.width);
            }
            
            lastController.view.frame = YSRectSetOriginX(lastController.view.frame, 0);
            
            [_controllers removeLastObject];
            [_controllers insertObject:lastController atIndex:0];
            
            [lastController release];
            
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + scrollView.frame.size.width, scrollView.contentOffset.y);
            _currentOffset += scrollView.frame.size.width;

        }
    }
}

- (void)setTitlesBackgroundImage:(UIImage *)titlesBackgroundImage {
    [_swipeBar setBackgroundImage:titlesBackgroundImage];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [_swipeBar setTextColor:titleColor.CGColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [_swipeBar setBackgroundColor:backgroundColor.CGColor];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    [_swipeBar setShadowColor:shadowColor.CGColor];
}

- (void)dealloc {
    [_controllers release];
    [_swipeBar release];
    [_controllersContainer release];
    [super dealloc];
}


@end


static NSInteger const kTitlesPositionRange = 160;
static CGFloat const kHorizontalMargin = 20.0;
static CGFloat const kYarikMagicNumber = 101.8592;

static CGFloat const kAdditionScaleFactor = 0.2;

@implementation ELSwipeBar

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    if (self) {
        self.opaque = YES;
    
        _fontSize = 10.0;
        
        _backgroundColor = YSColorCreateWhite();
        _textColor = YSColorCreateBlack();
        _shadowColor = YSColorCreateWithRGB(0x777777);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self init];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withRight:(NSString *)rTitle center:(NSString *)cTitle left:(NSString *)lTitle  {
    
    [_rightTitle autorelease];
    _rightTitle = [rTitle copy];
    if (!_rightTitle) {
        _rightTitle = [NSString string];
    }

    [_centerTitle autorelease];
    _centerTitle = [cTitle copy];
    if (!_centerTitle) {
        _centerTitle = [NSString string];
    }
    
    [_leftTitle autorelease];
    _leftTitle = [lTitle copy];
    if (!_leftTitle) {
        _leftTitle = [NSString string];
    }
    
    _globalScrollShift = (int)scrollView.contentOffset.x % (int)CGRectGetWidth(self.bounds);
    [self setNeedsDisplay];
}

CGAffineTransform scaleFunction(CGFloat x);

CGFloat positionFunction(CGFloat x, CGFloat a, CGFloat verticalShift, CGFloat rangeShift,  Boolean debug);

void addTriangle(CGMutablePathRef path, CGFloat base);

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1, -1);
    
    CGContextClearRect(context, rect);

    if (_backgroundImage) {
        
        [_backgroundImage drawAsPatternInRect:rect];
        
    } else {
        
        CGContextSetFillColorWithColor(context, _backgroundColor);
        CGContextFillRect(context, rect);
    }
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, _textColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0.5, _shadowColor);
    
    //drawing triangles
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat h = 4;
    CGPathMoveToPoint(path, NULL, 8, floorf(7 / 2) + 8);
    CGPathAddLineToPoint(path, NULL, 8 + h, 7);
    CGPathAddLineToPoint(path, NULL, 8 + h, 8 + 7);
    CGPathCloseSubpath(path);
    
    if ([_leftTitle length] > 0) {
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFill);
    }
    
    CGContextTranslateCTM(context, CGRectGetWidth(rect), 0);
    CGContextScaleCTM(context, -1, 1);
    
    if ([_rightTitle length] > 0) {
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFill);
    }
    
    CGPathRelease(path);
    
    CGContextRestoreGState(context);
    
    CGContextAddRect(context, CGRectMake(8 + h + 2, 0, CGRectGetWidth(rect) - 16 - 2 * h - 4, CGRectGetHeight(rect)));
    CGContextClip(context);
    
    CFStringRef helveticaNeue = CFSTR("HelveticaNeue-Bold");
    
    CTFontRef font = CTFontCreateWithName(helveticaNeue, _fontSize, NULL);
    
    CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
    CFTypeRef values[] = { font, _textColor };
    
    CFDictionaryRef attribs = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFRelease(font);
    
    CFMutableAttributedStringRef leftString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(leftString, CFRangeMake(0, 0), (CFStringRef)_leftTitle);
    CFAttributedStringSetAttributes(leftString, CFRangeMake(0, [_leftTitle length]), attribs, false);
    CFMutableAttributedStringRef centerString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(centerString, CFRangeMake(0, 0), (CFStringRef)_centerTitle);
    CFAttributedStringSetAttributes(centerString, CFRangeMake(0, [_centerTitle length]), attribs, false);
    CFMutableAttributedStringRef rightString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(rightString, CFRangeMake(0, 0), (CFStringRef)_rightTitle);
    CFAttributedStringSetAttributes(rightString, CFRangeMake(0, [_rightTitle length]), attribs, false);
    
    CFRelease(attribs);
    
    CTLineRef leftLine = CTLineCreateWithAttributedString(leftString);
    CTLineRef centerLine = CTLineCreateWithAttributedString(centerString);
    CTLineRef rightLine = CTLineCreateWithAttributedString(rightString);
    
    double centerWidth = CTLineGetTypographicBounds(centerLine, NULL, NULL, NULL);
    double rightWidth = CTLineGetTypographicBounds(rightLine, NULL, NULL, NULL);
    
    CGFloat verticalTextPorition = ceilf(CGRectGetHeight(rect) / 2 - _fontSize / 2 + 2);

    // We using function to determine x position of text
    // The function with respect to x (position function), 
    // where x is scroll offset, in global looks like:
    //
    //          ax    x              x    ax
    // f(x) = - --- - - + a + floor( - )*(-- + 160 - 2a); 
    //          160   2             160   80
    //
    // a - value for x = 0, whitch gives vertical shift only for function edges,    
    // but not central point of function break;
    //    
    
    CGFloat leftShift = positionFunction(_globalScrollShift, - kTitlesPositionRange / 12, kHorizontalMargin + kTitlesPositionRange / 12, kTitlesPositionRange/6, false);
    CGFloat centerShift = positionFunction(_globalScrollShift, - centerWidth / 2, kTitlesPositionRange, 2*kHorizontalMargin, false);        
    CGFloat rightShift = positionFunction(_globalScrollShift, - rightWidth + kTitlesPositionRange / 12, 2 * kTitlesPositionRange-kHorizontalMargin - kTitlesPositionRange / 12, kTitlesPositionRange / 6, false);
    
    CFRelease(leftLine);
    CFRelease(centerLine);
    CFRelease(rightLine);
    
    CGAffineTransform leftFontSize = scaleFunction(leftShift);
    CGAffineTransform centerFontSize = scaleFunction(centerShift);
    CGAffineTransform rightFontSize = scaleFunction(rightShift);
    
    CTFontRef leftFont = CTFontCreateWithName(helveticaNeue, _fontSize, &leftFontSize);
    CTFontRef centerFont = CTFontCreateWithName(helveticaNeue, _fontSize, &centerFontSize);
    CTFontRef rightFont = CTFontCreateWithName(helveticaNeue, _fontSize, &rightFontSize);
    
    CFAttributedStringSetAttribute(leftString, CFRangeMake(0, [_leftTitle length]), kCTFontAttributeName, leftFont);
    CFAttributedStringSetAttribute(centerString, CFRangeMake(0, [_centerTitle length]), kCTFontAttributeName, centerFont);
    CFAttributedStringSetAttribute(rightString, CFRangeMake(0, [_rightTitle length]), kCTFontAttributeName, rightFont);
    
    CFRelease(leftFont);
    CFRelease(centerFont);
    CFRelease(rightFont);
    
    leftLine = CTLineCreateWithAttributedString(leftString);
    centerLine = CTLineCreateWithAttributedString(centerString);
    rightLine = CTLineCreateWithAttributedString(rightString);
    
    CFRelease(leftString);
    CFRelease(centerString);
    CFRelease(rightString);
    
    CGContextSaveGState(context);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1.0, _shadowColor);
    
    CGContextSetTextPosition(context, leftShift, verticalTextPorition);
    CTLineDraw(leftLine, context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    CGContextSetTextPosition(context, centerShift, verticalTextPorition);
    CTLineDraw(centerLine, context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextSetTextPosition(context, rightShift, verticalTextPorition);
    CTLineDraw(rightLine, context);
    
    CGContextRestoreGState(context);
    
    
    CFRelease(leftLine);
    CFRelease(centerLine);
    CFRelease(rightLine);
}

CGFloat positionFunction(CGFloat x, CGFloat a, CGFloat verticalShift, CGFloat rangeShift, Boolean debug) {
    
    CGFloat (^function)(CGFloat, CGFloat, CGFloat, CGFloat) = ^(CGFloat x, CGFloat verticalShift, CGFloat a, CGFloat rangeShift) {
        return ceilf(- x * ((a + kTitlesPositionRange / 2 - rangeShift / 2) / kTitlesPositionRange) + a + (a * x / (kTitlesPositionRange / 2) + (kTitlesPositionRange - rangeShift) - 2 * a) * (BOOL)floor(x / kTitlesPositionRange) + verticalShift);
    };
    static CGFloat shift = 0;
    static BOOL printed =  NO;
    static int printedCount = 0;
    
    if (shift != verticalShift && printedCount != 3) {
        printed = NO;
        shift = verticalShift;
    }
    
    if (debug && !printed) {
        printed = YES;
        for (int i = 0; i < 320; i++) {
            NSLog(@"f(%d) = %1.2f", i ,function(i, verticalShift, a, rangeShift));
        }
        NSLog(@"-------------------");
        printedCount++;

    }
    
    return function(x, verticalShift, a, rangeShift);
}

CGAffineTransform scaleFunction(CGFloat x) {
    if (x < 80 || x > 240 ) {
        return CGAffineTransformIdentity;
    }
    return CGAffineTransformMakeScale(1.0 + kAdditionScaleFactor * (sinf((x - 82) / 50)),1.0 + kAdditionScaleFactor * (sinf((x - 82) / 50)));
}

void addTriangle(CGMutablePathRef path, CGFloat base) {
    CGFloat h = floorf(base * 8/7 / 2);
    CGPathMoveToPoint(path, NULL, 8, floorf(base / 2) + 6);
    CGPathAddLineToPoint(path, NULL, 8 + h, 6);
    CGPathAddLineToPoint(path, NULL, 8 + h, 6 + base);
    CGPathCloseSubpath(path);
}

- (void)setTextColor:(CGColorRef)textColor {
    CGColorRetain(textColor);
    CGColorRelease(_textColor);
    _textColor = textColor;
}

- (void)setShadowColor:(CGColorRef)shadowColor {
    CGColorRelease(_shadowColor);
    _shadowColor = CGColorRetain(shadowColor);
}

- (void)setBackgroundColor:(CGColorRef)backgroundColor {
    CGColorRelease(_backgroundColor);
    _backgroundColor = CGColorRetain(backgroundColor);
}

- (void)setBackgroundImage:(UIImage *)image {
    [_backgroundImage release];
    _backgroundImage = [image retain];
}

- (void)dealloc {
    [_centerTitle release];
    [_leftTitle release];
    [_rightTitle release];
    [super dealloc];
}
@end



