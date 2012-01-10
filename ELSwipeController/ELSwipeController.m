//
//  ELViewController.m
//  ELSwipeController
//
//  Created by Yarik Smirnov on 28.12.11.
//  Copyright (c) 2011 e-legion ltd. All rights reserved.
//

#import "ELSwipeController.h"
#import "YSDrawingKit.h"
#include "math.h"

@interface ELSwipeBar : UIView <UIScrollViewDelegate> {
    NSString    *_leftTitle;
    NSString    *_rightTitle;
    NSString    *_centerTitle;
    CGFloat     _globalScrollShift;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withRight:(NSString *)rTitle center:(NSString *)cTitle left:(NSString *)lTitle;

@end

@interface ELSwipeController (Internal) <UIScrollViewDelegate>

- (void)loadNeededControllersForIndex:(NSInteger)index;

@end

@implementation ELSwipeController

- (id)initWithControllersStack:(NSArray *)controllers {
    if (!controllers) {
        NSAssert(controllers, @"Controllers must not be nil.");
        return nil;
    }
    self = [super init];
    if (self) {
        _controllers = [controllers mutableCopy];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIScreen *screen = [UIScreen mainScreen];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    CGSize size = CGSizeMake(screen.bounds.size.width, screen.bounds.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - app.statusBarFrame.size.height);
    
    CGRect mainViewFrame = CGRectZero;
    
    mainViewFrame = YSRectSetSize(mainViewFrame, size);
    
    _controllersContainer = [[UIScrollView alloc] initWithFrame:mainViewFrame];
    _controllersContainer.pagingEnabled = YES;
    _controllersContainer.delegate = self;
    _controllersContainer.showsVerticalScrollIndicator = NO;
    _controllersContainer.showsHorizontalScrollIndicator = NO;
    _controllersContainer.contentSize = CGSizeMake(_controllersContainer.frame.size.width * [_controllers count] + 1, _controllersContainer.contentSize.height);
    
    _swipeBar = [[ELSwipeBar alloc] init];
    [self.view addSubview:_swipeBar];
    _swipeDelegate = _swipeBar;
    [_swipeBar release];
    
    _controllersContainer.frame  = YSRectSetHeight(_controllersContainer.frame, CGRectGetHeight(_controllersContainer.frame) - CGRectGetHeight(_swipeBar.frame));
    _controllersContainer.frame = YSRectSetOriginY(_controllersContainer.frame, CGRectGetHeight(_swipeBar.frame));
    
    for (int i = 0; i < [_controllers count]; i++) {
        UIViewController *viewController = [_controllers objectAtIndex:i];
        viewController.view.frame = YSRectSetOriginX(viewController.view.frame, self.view.frame.size.width*i);
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

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1, -1);
    
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillRect(context, rect);
        
    CGContextSelectFont(context, "Helvetica", 14, kCGEncodingMacRoman);
    
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextSetTextPosition(context, 0, 0);
    CGContextShowText(context, [_centerTitle cStringUsingEncoding:NSUTF8StringEncoding], [_centerTitle length]);
    CGPoint centerWidth = CGContextGetTextPosition(context);

    CGContextSetTextPosition(context, 0, 0);
    CGContextShowText(context, [_rightTitle cStringUsingEncoding:NSUTF8StringEncoding], [_rightTitle length]);
    CGPoint rigthWidth = CGContextGetTextPosition(context);
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, YSColorGetFromHex(0xFFFFFF));
    
    CGFloat verticalTextPorition = CGRectGetHeight(rect)/2 - 7;

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
    CGFloat centerShift = positionFunction(_globalScrollShift, - centerWidth.x / 2, kTitlesPositionRange, 2*kHorizontalMargin, false);        
    CGFloat rightShift = positionFunction(_globalScrollShift, - rigthWidth.x + kTitlesPositionRange / 12, 2 * kTitlesPositionRange-kHorizontalMargin - kTitlesPositionRange / 12, kTitlesPositionRange / 6, false);
    
    CGContextSetTextMatrix(context, scaleFunction(leftShift));
    CGContextSetTextPosition(context, leftShift, verticalTextPorition);
    CGContextShowText(context, [_leftTitle cStringUsingEncoding:NSUTF8StringEncoding], [_leftTitle length]);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    
    CGContextSetTextMatrix(context, scaleFunction(centerShift));
    CGContextSetTextPosition(context, centerShift, verticalTextPorition);
    CGContextShowText(context, [_centerTitle cStringUsingEncoding:NSUTF8StringEncoding], [_centerTitle length]);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextSetTextMatrix(context, scaleFunction(rightShift));
    CGContextSetTextPosition(context, rightShift, verticalTextPorition);
    CGContextShowText(context, [_rightTitle cStringUsingEncoding:NSUTF8StringEncoding], [_rightTitle length]);
    
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
    return CGAffineTransformScale(CGAffineTransformIdentity ,1.0 + kAdditionScaleFactor * (sinf((x - 82) / 50)),1.0 + kAdditionScaleFactor * sinf((x - 82) / 50));
}

- (void)dealloc {
    [_centerTitle release];
    [_leftTitle release];
    [_rightTitle release];
    [super dealloc];
}
@end
