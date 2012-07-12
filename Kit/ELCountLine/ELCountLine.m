//
//  ELPriceLine.m
//  iOSKit
//
//  Created by Yarik Smirnov on 6/25/12.
//  Copyright (c) 2012 Yarik Smirnov. All rights reserved.
//

#import "ELCountLine.h"
#import "CoreText/CoreText.h"
#import "ELUtils.h"

@implementation ELCountLine
@synthesize fontSize = _fontSize;
@synthesize isBold = _isBold;
@synthesize textColor = _textColor;
@synthesize titleSize = _titleSize;
@synthesize titleColor = _titleColor;

- (id)initWithTitle:(id)title andPrice:(NSNumber *)price {
    self = [self initWithFrame:CGRectMake(0, 0, 320, 25)];
    if (self) {
        _title = [[title description] copy];
        [self setPrice:price]; 
    }
    return self;
}

- (void)setPrice:(NSNumber *)number {
    [_price release];
    _price = [ELStringByGroupingNumber(number) retain];
    
    [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [_titleColor release];
    _titleColor = titleColor;
    [self setNeedsDisplay];
}

- (void)setFontSize:(NSInteger)fontSize {
    _fontSize = fontSize;
    _titleSize = fontSize;
    [self setNeedsDisplay];
}

- (void)setTitleSize:(NSInteger)titleSize {
    _titleSize = titleSize;
    [self setNeedsDisplay];
}

- (void)setIsBold:(BOOL)isBold {
    _isBold = isBold;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _fontSize = 14;
        _titleSize = _fontSize;
        _textColor = [UIColor blackColor];
        _titleColor = [UIColor blackColor];
        self.opaque = NO;
    }
    return self;
}

- (void)setTitle:(NSString *)title andPrice:(NSNumber *)price {
    [_title release];
    _title = [[title description] copy];
    [self setPrice:price];
}

- (void)dealloc {
    self.textColor = nil;
    [_price release];
    [_title release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1, -1);
    
    CGContextClearRect(context, rect);
    
    YSFontStyleId fontStyle = kYSFontStyleRegular;
    if (self.isBold) {
        fontStyle = kYSFontStyleBold;
    }
    
    CTFontRef font        =        YSFontCreateFromWithNameAndStyle(kYSFontFamilyNameArial, fontStyle, _fontSize);
    CTFontRef titleFont   =        YSFontCreateFromWithNameAndStyle(kYSFontFamilyNameArial, fontStyle, _titleSize);
        
    CFTypeRef values[]      =   { font, _textColor.CGColor};
    CFTypeRef titleValue[]  =   { titleFont, _titleColor.CGColor};
    CFStringRef keys[]      =   { kCTFontAttributeName, kCTForegroundColorAttributeName };
    
    
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryRef titleAttributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&titleValue, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); 
    
    CFAttributedStringRef attributedString =  CFAttributedStringCreate(kCFAllocatorDefault, CFSTR("."), titleAttributes);
    CTLineRef dotLine = CTLineCreateWithAttributedString(attributedString);
    
    static float dotSize = 0;
    if (!dotSize) {
        
        CGContextSetTextDrawingMode(context, kCGTextInvisible);
        
        CTLineDraw(dotLine, context);
        CGPoint position = CGContextGetTextPosition(context);

        dotSize = rintf(position.x); 
        
        CGContextSetTextPosition(context, 0, 0);
    }
    
    CFRelease(attributedString);
    CFRelease(font);
    CFRelease(titleFont);
    
    CFAttributedStringRef titleString = CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)_title, titleAttributes);
    CFAttributedStringRef priceString = CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)_price, attributes);
    
    CFRelease(attributes);
    CFRelease(titleAttributes);
    
    CTLineRef titleLine = CTLineCreateWithAttributedString(titleString);
    CTLineRef priceLine = CTLineCreateWithAttributedString(priceString);
    
    CFRelease(titleString);
    CFRelease(priceString);
    
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    
    CTLineDraw(priceLine, context);
    
    CGPoint priceSize = CGContextGetTextPosition(context);
    
    CGContextSetTextPosition(context, CGRectGetWidth(rect) - rintf(priceSize.x), 4);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    CTLineDraw(priceLine, context);
    CGContextSetTextPosition(context, 0, 4);

    CTLineDraw(titleLine, context);
    
    while (true) {
        CGPoint position = CGContextGetTextPosition(context);
        
        if (position.x > CGRectGetWidth(rect) - rintf(priceSize.x) - dotSize) {
            break;
        }
        CTLineDraw(dotLine, context);
    }
    
    CFRelease(titleLine);
    CFRelease(priceLine);
    
    CFRelease(dotLine);
}


@end
