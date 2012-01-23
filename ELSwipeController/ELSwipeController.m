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
    
    CGImageRef  _backgroundImage;
    
    CGFloat     _fontSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withRight:(NSString *)rTitle center:(NSString *)cTitle left:(NSString *)lTitle;

- (void)setTextColor:(CGColorRef)textColor;

- (void)setShadowColor:(CGColorRef)shadowColor;

- (void)setBackgroundColor:(CGColorRef)backgroundColor;

- (void)setBackgroundImage:(CGImageRef)image;

@end


@interface ELSwipeController (Internal) <UIScrollViewDelegate>

- (void)loadNeededControllersForIndex:(NSInteger)index;

@end

@implementation ELSwipeController

@synthesize titleColor = _titleColor;
@synthesize shadowColor = _shadowColor;
@synthesize fontSize = _fontSize;
@synthesize titleBackgroundColor = _titleBackgroundColor;
@synthesize backgroundColor = _backgroundColor;
@synthesize titlesBackgroundImage = _titlesBackgroundImage;

- (id)initWithControllersStack:(NSArray *)controllers {
    if (!controllers) {
        NSAssert(controllers, @"Controllers must not be nil.");
        return nil;
    }
    self = [super init];
    if (self) {
        _controllers = [controllers mutableCopy];
        
        _controllersContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _controllersContainer.pagingEnabled = YES;
        _controllersContainer.delegate = self;
        _controllersContainer.showsVerticalScrollIndicator = NO;
        _controllersContainer.showsHorizontalScrollIndicator = NO;
        
        _swipeBar = [[ELSwipeBar alloc] init];
        _swipeDelegate = _swipeBar;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:_swipeBar];
    [_swipeBar release];
    
    UIScreen *screen = [UIScreen mainScreen];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    CGSize size = CGSizeMake(screen.bounds.size.width, screen.bounds.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.tabBarController.tabBar.frame.size.height - app.statusBarFrame.size.height - CGRectGetHeight(_swipeBar.frame));
    
    CGRect mainViewFrame = CGRectZero;
    
    mainViewFrame = YSRectSetSize(mainViewFrame, size);
    
    _controllersContainer.frame = mainViewFrame;
    _controllersContainer.contentSize = CGSizeMake(_controllersContainer.frame.size.width * [_controllers count] + 1, _controllersContainer.contentSize.height);
    
    _controllersContainer.frame = YSRectSetOriginY(_controllersContainer.frame, CGRectGetHeight(_swipeBar.frame));
    
    
    for (int i = 0; i < [_controllers count]; i++) {
        UIViewController *viewController = [_controllers objectAtIndex:i];
        viewController.view.frame = YSRectSetOriginX(viewController.view.frame, CGRectGetWidth(self.view.frame)*i);
        viewController.view.frame = YSRectSetOriginY(viewController.view.frame, 0);
        viewController.view.frame = YSRectSetSize(viewController.view.frame, _controllersContainer.frame.size);
        [_controllersContainer addSubview:viewController.view];
    }
        
    [self.view addSubview:_controllersContainer];
    [_controllersContainer release];
    
    [self scrollViewDidScroll:_controllersContainer];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger currentController = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    NSInteger index = currentController;

    
    NSString *center = [[_controllers objectAtIndex:index] title];
    NSString *left = index > 0 ? [[_controllers objectAtIndex:index - 1] title] : [[_controllers lastObject] title];
    NSString *right = index <= [_controllers count] - 2 ? [[_controllers objectAtIndex:index + 1] title] : [[_controllers objectAtIndex:0] title];
                      
    [_swipeDelegate scrollViewDidScroll:scrollView withRight:right center:center left:left];
    
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
    }
}

- (void)setTitlesBackgroundImage:(UIImage *)titlesBackgroundImage {
    [_swipeBar setBackgroundImage:titlesBackgroundImage.CGImage];
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


@end


static NSInteger const kTitlesPositionRange = 160;
static CGFloat const kHorizontalMargin = 20.0;
static CGFloat const kYarikMagicNumber = 101.8592;

static CGFloat const kAdditionScaleFactor = 0.2;

@implementation ELSwipeBar

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 17)];
    if (self) {
        self.opaque = YES;
    
        _fontSize = 8.0;
        
        _backgroundColor = YSColorGetFromHex(0xFFFFFF);
        CGColorRetain(_backgroundColor);
        _textColor = YSColorGetFromHex(0x0);
        CGColorRetain(_textColor);
        _shadowColor = YSColorGetFromHex(0x777777);
        CGColorRetain(_shadowColor);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self init];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withRight:(NSString *)rTitle center:(NSString *)cTitle left:(NSString *)lTitle  {
    
    [_rightTitle autorelease];
    _rightTitle = [rTitle copy];

    [_centerTitle autorelease];
    _centerTitle = [cTitle copy];
    
    [_leftTitle autorelease];
    _leftTitle = [lTitle copy];
    
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
        
        size_t imageWidth = CGImageGetWidth(_backgroundImage);
        size_t imageHeght = CGImageGetHeight(_backgroundImage);
        CGSize imageSize = CGSizeMake(imageWidth, imageHeght);
        CGRect imageRect = CGRectMake(0, 0, imageWidth, CGRectGetHeight(rect));
        
        CGLayerRef bgLayer = CGLayerCreateWithContext(context, imageSize, NULL);
        CGContextRef layerContext = CGLayerGetContext(bgLayer);
        
        CGContextDrawImage(layerContext, imageRect, _backgroundImage);
        
        CGContextSaveGState(context);
        for (int i = 0; i < rect.size.width / CGImageGetWidth(_backgroundImage); i++) {
        
            CGContextDrawLayerAtPoint(context, CGPointZero, bgLayer);
            CGContextTranslateCTM(context, imageWidth, 0.0);
            
        }
        CGContextRestoreGState(context);
        
        CGLayerRelease(bgLayer);
        
    } else {
        
        CGContextSetFillColorWithColor(context, _backgroundColor);
        CGContextFillRect(context, rect);
    }
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, _textColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0.5, _shadowColor);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat h = floorf(7 * 8/7 / 2);
    CGPathMoveToPoint(path, NULL, 8, floorf(7 / 2) + 6);
    CGPathAddLineToPoint(path, NULL, 8 + h, 6);
    CGPathAddLineToPoint(path, NULL, 8 + h, 6 + 7);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextTranslateCTM(context, CGRectGetWidth(rect), 0);
    CGContextScaleCTM(context, -1, 1);
    
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFill);
    
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
    
    CGFloat verticalTextPorition = ceilf(CGRectGetHeight(rect) / 2 - _fontSize / 2 + 1);

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

- (void)setBackgroundImage:(CGImageRef)image {
    CGImageRelease(_backgroundImage);
    _backgroundImage = CGImageRetain(image);
}

- (void)dealloc {
    [_centerTitle release];
    [_leftTitle release];
    [_rightTitle release];
    [super dealloc];
}
@end



