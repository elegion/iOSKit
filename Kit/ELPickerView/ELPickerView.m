//
//  ELPickerView.m
//  
//
//  Created by Yarik Smirnov on 12/12/11.
//  Copyright (c) 2011 e-Legion ltd. All rights reserved.
//

#import "ELPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "YSDrawingKit.h"

static CGFloat const _kDefaultDigitWidth        = 33;
static CGFloat const _kDefaultDigitHeight       = 37;
static CGFloat const _kDefaultDigitWidthLarge   = 40;

static CGFloat  const _kDefaultScrollInset = 30;
static CGFloat  const _kDefaultScrollInsetLarge = 73;

enum {
    _kELCenterEdgesIndex,
    _kELCenterGraphicIndex,
    _kELMainGraphicIndex
};

@class ELPickerDigit;
@interface ELPickerCenter : UIView <UIScrollViewDelegate> {
    CGPoint _lastOffset;
    ELPickerDigit *_leftDigit;
    ELPickerDigit *_rightDigit;
        
    NSRange _range;

}
@property (nonatomic, assign) BOOL useLargeAppearence;
- (void)setGraphic:(NSString *)imageName;
- (void)setRange:(NSRange)range;
- (void)setLeftValue:(NSInteger)value;
- (void)setRigthValue:(NSInteger)value;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface YSShadowRect :UIView
@end

@interface YSRollShadow : UIView
@property(nonatomic, assign) BOOL inverseGradient;
@end

typedef enum {
    _ELDIGITSMALL,
    _ELDIGITLARGE
} _ELDIGITSTYLE;

@interface ELPickerDigit : UIView {
@private
    NSInteger _currentValue;
    NSString *_stringValue;
    CGSize _shadowOffset;
    
    struct {
        unsigned int digitStyle:16;
        unsigned int digitColor:24;
        unsigned int shadowColor:24;
    } _digitFlags;
    
}

- (id)initWithDigit:(NSInteger)digit;
- (void)setValue:(NSInteger)value;
- (void)setShadowColor:(NSUInteger)shadowColor offset:(CGSize)offset;
- (void)setDigitColor:(NSInteger)colorInHex;
- (NSInteger)currentValue;
@end


@interface ELPickerView (Internal) <UIScrollViewDelegate> 

- (void)initializeContent;
- (void)setRightPosition;
- (void)notifyDelegate;
    
@end

@implementation ELPickerView
@synthesize delegate = _delegate;
@synthesize graphicImagesNames = _graphicsNames;
@synthesize pickerStyle = _pickerStyle;

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame {
    self = [self initWithRange:range andFrame:frame andStyle:ELPickerViewStyleSmall];
    return self;
}

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame andStyle:(ELPickerViewStyle)style {
    CGSize size = CGSizeMake(97, 54);
    if (style == ELPickerViewStyleLarge) {
        size = CGSizeMake(245, 62);
    }
    self = [super initWithFrame:YSRectSetSize(frame, size)];
    if (self) {
        _pickerStyle = style;
        _range = range;
        _currentSelection = _range.location;
        _graphicsNames = [[NSArray alloc] initWithObjects:@"center_edges.png", @"center_graphic.png", @"main_graphic.png", nil];
        [self initializeContent];
    }
    return self;
}

- (void)initializeContent {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 9, 93, 37)];
    if (_pickerStyle == ELPickerViewStyleLarge) {
        _scrollView.frame = CGRectMake(31, 12, 184, 37);
    }
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(_kDefaultDigitWidth*_range.length + 2*_kDefaultScrollInset, _kDefaultDigitHeight);
    if (_pickerStyle == ELPickerViewStyleLarge) {
        _scrollView.contentSize = CGSizeMake(_kDefaultDigitWidthLarge*_range.length + 2*_kDefaultScrollInsetLarge, _kDefaultDigitHeight);
    }
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollView];
    [_scrollView release];
    
    for (int i = 0; i < _range.length; i++) {
        ELPickerDigit *digit = [[ELPickerDigit alloc] initWithDigit:_range.location + i];
        digit.frame = CGRectMake(_kDefaultDigitWidth*i + _kDefaultScrollInset, 0, _kDefaultDigitWidth, _kDefaultDigitHeight);
        if (_pickerStyle == ELPickerViewStyleLarge) {
                digit.frame = CGRectMake(_kDefaultDigitWidthLarge*i + _kDefaultScrollInsetLarge, 0, _kDefaultDigitWidthLarge, _kDefaultDigitHeight);
        }
        [_scrollView addSubview:digit];
        [digit setValue:_range.location + i];
        digit.tag = _range.location + i;
        [digit release];
    }
    
    _center = [[ELPickerCenter alloc] init];
    _forwardResponder = _center;
    [_center setLeftValue:_range.location + 1];
    [_center setRigthValue:_range.location];
    [_center setRange:_range];
    [self addSubview:_center];
    [_center release];
    
    if (_pickerStyle == ELPickerViewStyleLarge) {
        _center.useLargeAppearence = YES;
    }

    //View shadow for center with native drawing
    
//    YSShadowRect *shadow = [[YSShadowRect alloc] init];
//    shadow.frame = CGRectMake(52/2, 0, 86/2, 108/2);
//    shadow.userInteractionEnabled = NO;
//    [self addSubview:shadow];
//    [shadow release];
    
    // Main graphic of roll with shadows and vertical edges
    _graphic = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    UIImage *image = [UIImage imageNamed:[_graphicsNames objectAtIndex:_kELMainGraphicIndex]];
    _graphic.image = image;
    [self addSubview:_graphic];
    [self sendSubviewToBack:_graphic];
    [_graphic release];
 
    // Vertical edges of center panel and shadow near
    if (_pickerStyle == ELPickerViewStyleSmall) {
        _edges = [[UIImageView alloc] initWithFrame:CGRectMake(_center.frame.origin.x - 4, 0, 41, 54)];
        UIImage *edgesImage = [UIImage imageNamed:[_graphicsNames objectAtIndex:_kELCenterEdgesIndex]];
        _edges.image = edgesImage;
        [self addSubview:_edges];
        [_edges release];
    }
}

- (void)setGraphicImagesNames:(NSArray *)graphicImagesNames {
    if ([graphicImagesNames count] > 0) {
        _edges.image = [UIImage imageNamed:[graphicImagesNames objectAtIndex:_kELCenterEdgesIndex]];
        if ([graphicImagesNames count] > 1) {
            [_center setGraphic:[graphicImagesNames objectAtIndex:_kELCenterGraphicIndex]];
            [_center setNeedsDisplay];
            if ([graphicImagesNames count] > 2) {
                _graphic.image = [UIImage imageNamed:[graphicImagesNames objectAtIndex:_kELMainGraphicIndex]];
            }
        }
    }
}

- (void)setSelection:(NSInteger)shiftFromLocation {
    [_scrollView setContentOffset:CGPointMake(((shiftFromLocation - 1) * _kDefaultDigitWidth), _scrollView.contentOffset.y)];
    if (_pickerStyle == ELPickerViewStyleLarge) {
        [_scrollView setContentOffset:CGPointMake(((shiftFromLocation - 1) * _kDefaultDigitWidthLarge), _scrollView.contentOffset.y)];
    }
    [self notifyDelegate];
}

- (void)setRightPosition {
    CGFloat width = _pickerStyle == ELPickerViewStyleLarge ? _kDefaultDigitWidthLarge : _kDefaultDigitWidth;
    NSInteger position = ((NSInteger)_scrollView.contentOffset.x % (NSInteger)width);
    
    if (position > width/2) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + (width - position), _scrollView.contentOffset.y) animated:YES];
    } else {
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x - position,_scrollView.contentOffset.y) animated:YES];
    }
    if (position == 0) {
        [self notifyDelegate];
    }
}


#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_forwardResponder scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegate respondsToSelector:@selector(pickerViewWillBeginScrollingAnimation)]) {
        [_delegate performSelector:@selector(pickerViewWillBeginScrollingAnimation)];
    }
    if (!decelerate) {
        [self setRightPosition];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setRightPosition];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self notifyDelegate];
}

- (void)notifyDelegate {
    _currentSelection = _scrollView.contentOffset.x / _kDefaultDigitWidth + 1;
    if (_pickerStyle == ELPickerViewStyleLarge) {
        _currentSelection = _scrollView.contentOffset.x / _kDefaultDigitWidthLarge + 1;
    }
    if ([_delegate respondsToSelector:@selector(pickerView:didSelectValue:)]) {
        [_delegate pickerView:self didSelectValue:_currentSelection];
    }
    if ([_delegate respondsToSelector:@selector(pickerViewDidiEndScrollingAnimation)]) {
        [_delegate performSelector:@selector(pickerViewDidiEndScrollingAnimation)];
    }
}

- (void)dealloc {
    _scrollView.delegate = nil;
    [_graphicsNames release];
    [super dealloc];
}


@end


@implementation ELPickerCenter
@synthesize useLargeAppearence = _useLargeAppearence;

- (id)init {
    self = [super initWithFrame:CGRectMake(32, 0, _kDefaultDigitWidth, 54)];
    if (self) {
        
        _leftDigit = [[ELPickerDigit alloc] initWithDigit:2];
        _leftDigit.frame = CGRectMake(-_kDefaultDigitWidth, 9, _kDefaultDigitWidth, _kDefaultDigitHeight);
        _rightDigit = [[ELPickerDigit alloc] initWithDigit:3];
        _rightDigit.frame = CGRectMake(0, 9, _kDefaultDigitWidth, _kDefaultDigitHeight);
        
        [_rightDigit setDigitColor:0xFFFFFF];
        [_rightDigit setShadowColor:0x0 offset:CGSizeMake(0, -1)];
        [_leftDigit  setDigitColor:0xFFFFFF];
        [_leftDigit setShadowColor:0x0 offset:CGSizeMake(0, -1)];
        
        self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
        
        
        [self addSubview:_leftDigit];
        [self addSubview:_rightDigit];
        
        //Backgound with supplied image
        UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIImage *image =[UIImage imageNamed:@"center_graphic.png"];
        back.image = image;
        [self addSubview:back];
        [self sendSubviewToBack:back];
        [back release];
    }
    return self;
}

- (void)setUseLargeAppearence:(BOOL)useLargeAppearence {
    _useLargeAppearence = useLargeAppearence;
    if (_useLargeAppearence) {
        _leftDigit.frame = CGRectMake(-_kDefaultDigitWidthLarge, 12, _kDefaultDigitWidthLarge, _kDefaultDigitHeight);
        _rightDigit.frame = CGRectMake(0, 12, _kDefaultDigitWidthLarge, _kDefaultDigitHeight);
        self.frame = CGRectMake(105, 0, 35, 62);
        [(UIImageView *)[self.subviews objectAtIndex:0] setFrame:YSRectSetSize(CGRectZero, self.bounds.size)];
    }
}

- (void)setRange:(NSRange)range {
    _range = range;
}

- (void)setLeftValue:(NSInteger)value {
    [_leftDigit setValue:value];
}

- (void)setRigthValue:(NSInteger)value {
    [_rightDigit setValue:value];
}

- (void)setGraphic:(NSString *)imageName {
    [(UIImageView *)[self.subviews objectAtIndex:0] setImage:[UIImage imageNamed:imageName]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = _useLargeAppearence ? _kDefaultDigitWidthLarge : _kDefaultDigitWidth;
    
    NSInteger currentPosition = ((NSInteger)scrollView.contentOffset.x % (NSInteger)width);
    NSInteger rigthShift = (currentPosition < 0) ? -width : width;
    
    CGFloat addonShift = _useLargeAppearence ? -1 : 0;
    if (scrollView.contentOffset.x < 0) {
        _leftDigit.frame = YSRectSetOriginX(_leftDigit.frame, -scrollView.contentOffset.x + rigthShift);
    } else {
        _leftDigit.frame = YSRectSetOriginX(_leftDigit.frame, -currentPosition + rigthShift + addonShift);
    }
    if (scrollView.contentOffset.x >= 0 || (scrollView.contentOffset.x < 0 && _rightDigit.frame.origin.x < width)) {
        _rightDigit.frame = YSRectSetOriginX(_rightDigit.frame, -currentPosition + addonShift);
    }
    
    CGRect leftRect = [scrollView convertRect:_leftDigit.frame fromView:self];
    CGRect rightRect = [scrollView convertRect:_rightDigit.frame fromView:self];
    
    [_leftDigit setValue:_range.location + ((leftRect.origin.x) / width) - (int)_useLargeAppearence];
    [_rightDigit setValue:_range.location + ((rightRect.origin.x)/ width) - (int)_useLargeAppearence];
    
    _leftDigit.hidden = ((_range.location + _range.length) < [_leftDigit currentValue] + 1) || ([_leftDigit currentValue] < _range.location);
    _rightDigit.hidden = ((_range.location + _range.length) < [_rightDigit currentValue] + 1) || ([_rightDigit currentValue] < _range.location);

    int digitCountEdge = _useLargeAppearence ? -4 : -2;
    if (scrollView.contentOffset.x < digitCountEdge*width) {
        scrollView.contentOffset = CGPointMake(digitCountEdge*width, scrollView.contentOffset.y);
    }
}

// Native background graphic drawing

//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context, 1, -1);
//    
//    CGContextClearRect(context, rect);
//    CGContextSetFillColorWithColor(context, YSColorGetFromHex(0xc030ac));
//    CGContextSetLineWidth(context, 2.0);
//    CGPathRef path = CGPathCreateWithRect(rect, NULL);
//    CGContextAddPath(context, path);
//    CGContextDrawPath(context, kCGPathFill);
//    CGPathRelease(path);
//}
@end

@implementation ELPickerDigit

- (id)initWithDigit:(NSInteger)digit {
    self = [super init];
    if (self) {
        [self setValue:digit];
        _digitFlags.digitColor = 0x9A9A9A;
        if (_digitFlags.digitStyle == _ELDIGITLARGE) {
            _digitFlags.digitColor = 0x808080;
        }
        _digitFlags.shadowColor = 0xFFFFFF;
        _shadowOffset = CGSizeMake(0, 1);
        self.opaque= NO;
    }
    return self;
}

- (void)setDigitColor:(NSInteger)colorInHex {
    _digitFlags.digitColor = colorInHex;
}

- (NSInteger)currentValue {
    return _currentValue;
}

- (void)setValue:(NSInteger)value {
    _currentValue = value;
    [_stringValue release];
    _stringValue = [[NSString alloc] initWithFormat:@"%d", _currentValue];
    [self setNeedsDisplay];
}

- (void)setShadowColor:(NSUInteger)shadowColor offset:(CGSize)offset {
    _digitFlags.shadowColor = shadowColor;
    _shadowOffset = offset;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(myContext, 0, self.bounds.size.height);
    CGContextScaleCTM(myContext, 1, -1);
    CGContextClearRect(myContext, rect);
    CGContextSelectFont (myContext, 
                         "HelveticaNeue-Bold",
                         22,
                         kCGEncodingMacRoman);

    CGFloat opacity = 100;
    if (_digitFlags.shadowColor == 0x0) {
        opacity = 37;
    }
    
    CGColorRef digitColor = YSColorCreateWithRGB(_digitFlags.digitColor);
    CGColorRef digitShadow = YSColorCreateWithRGBAndAlpha(_digitFlags.shadowColor, opacity);
    
    CGContextSetFillColorWithColor(myContext, digitColor);
    
    // Setting center text aligment
    CGContextSetTextPosition(myContext, 0, 0);
    CGContextSetTextDrawingMode (myContext, kCGTextInvisible);
    CGContextShowText(myContext, [_stringValue cStringUsingEncoding:NSUTF8StringEncoding], [_stringValue length]);
    CGPoint endTextPosition = CGContextGetTextPosition(myContext);
    CGFloat xPosition = (self.bounds.size.width - endTextPosition.x) / 2;
    
    CGContextSaveGState(myContext);
    CGContextSetShadowWithColor(myContext, _shadowOffset, 0, digitShadow);
    CGContextSetTextDrawingMode (myContext, kCGTextFill);
    CGContextShowTextAtPoint (myContext, floorf(xPosition) , 10, [_stringValue cStringUsingEncoding:NSUTF8StringEncoding], [_stringValue length]);
    CGContextRestoreGState(myContext);
    
    CGColorRelease(digitColor);
    CGColorRelease(digitShadow);
}

- (void)dealloc {
    [_stringValue release];
    [super dealloc];
}

@end


@implementation YSShadowRect

- (id)init {
    self = [super init];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //    CGContextScaleCTM(context, 1, -1);
    
    CGContextClearRect(context, rect);
    
    CGFloat location[2] = {0.0, 1.0};
    CGColorRef colorValues[2] = {YSColorGetFromHexAndAlpha(0xCCCCCC, 30), YSColorGetFromHexAndAlpha(0xCCCCCC, 0)};
    CFArrayRef colors = CFArrayCreate(kCFAllocatorDefault, (void *)colorValues, 2, NULL);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, colors, location); 
    
    CFRelease(colors);
    
    CGContextSaveGState(context);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextAddRect(context, CGRectMake(self.bounds.origin.x + 6/2, self.bounds.origin.y, self.bounds.size.width - 12/2, self.bounds.size.height));
    CGContextAddRect(context, CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 6/2, self.bounds.size.width, self.bounds.size.height - 12/2));
    CGContextClip(context);
    
    const CGPoint startPoints[4] = {CGPointMake(self.bounds.origin.x + 6/2, self.bounds.size.height/2),
                                    CGPointMake(self.bounds.size.width/2, self.bounds.origin.y + 6/2),
                                    CGPointMake(self.bounds.size.width - 6/2, self.bounds.size.height/2),
                                    CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 6/2)};
    
    const CGPoint endPoints[4] = {  CGPointMake(self.bounds.origin.x, self.bounds.size.height/2),
                                    CGPointMake(self.bounds.size.width/2, self.bounds.origin.y),
                                    CGPointMake(self.bounds.size.width, self.bounds.size.height/2),
                                    CGPointMake(self.bounds.size.width/2, self.bounds.size.height)};
    
    for (int i = 0; i < 4; i ++) {
        CGContextDrawLinearGradient(context, gradient, startPoints[i], endPoints[i], 0);
    }
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    CGContextAddRect(context, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 6/2, 6/2));
    CGContextAddRect(context, CGRectMake(self.bounds.origin.x, self.bounds.size.height - 6/2, 6/2, 6/2));
    CGContextAddRect(context, CGRectMake(self.bounds.size.width - 6/2, self.bounds.origin.y, 6/2, 6/2));
    CGContextAddRect(context, CGRectMake(self.bounds.size.width - 6/2, self.bounds.size.height - 6/2, 6/2, 6/2));
    CGContextClip(context);
    
    const CGPoint centers[4] = {    CGPointMake(self.bounds.origin.x + 6/2, self.bounds.origin.y + 6/2),
                                    CGPointMake(self.bounds.size.width - 6/2, self.bounds.origin.y + 6/2),
                                    CGPointMake(self.bounds.size.width - 6/2, self.bounds.size.height - 6/2),
                                    CGPointMake(self.bounds.origin.x + 6/2, self.bounds.size.height - 6/2)};
    
    for (int i = 0; i < 4; i++) {
        CGContextDrawRadialGradient(context, gradient, centers[i], 0, centers[i], 6/2, 0);
    }
    
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, YSColorGetFromHex(0xFFFFFF));
    CGContextSetLineWidth(context, 1.0);
    
    CGContextAddRect(context, CGRectMake(self.bounds.origin.x + 6/2, self.bounds.origin.y + 6/2, self.bounds.size.width - 12/2, self.bounds.size.height - 12/2));
    CGContextDrawPath(context, kCGPathStroke);
    
    
}

@end

@implementation YSRollShadow
@synthesize inverseGradient;

- (id)init {
    self = [super init];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    //Gradient for roll
    //
    //Using png in this version
    
}

@end
