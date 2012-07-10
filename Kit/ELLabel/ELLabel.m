//
//  ELLabel.m
//  iOSKit
//
//  Created by Yarik Smirnov on 6/28/12.
//  Copyright (c) 2012 Yarik Smirnov. All rights reserved.
//

#import "ELLabel.h"
#import <CoreText/CoreText.h>
#import "ELUtils.h"

@implementation ELLabel
@synthesize leading = _leading;
@synthesize textColor = _textColor;
@synthesize textAligment = _aligment;
@synthesize text = _text;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize verticalAligment = _verticalAligment;
@synthesize renderedTextSize;


@synthesize font = _font;
@synthesize ctFont = _ctFont;

@synthesize title = _title;
@synthesize titleColor = _titleColor;
@synthesize titleFont = _titleFont;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;   
        self.userInteractionEnabled = NO;
        
        _leading = 0;
        _textColor = [UIColor blackColor];
        _textAligment = kCTLeftTextAlignment;
        _text = [NSString string];
        _shadowColor = [[UIColor darkGrayColor] retain];
        _shadowOffset = CGSizeMake(0, 0);
        
        _ctFont = YSFontCreateFromWithNameAndStyle(kYSFontFamilyNameHelveticaNeue, kYSFontStyleRegular, 14.0);
        
        _shadowColor = [[UIColor colorFromHex:0x0 alpha:30] retain];
        
        _title = [NSString string];
        _titleColor = [_textColor retain];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
        [_title release];
        _title = [title copy];
        [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (titleColor) {
        [_titleColor release];
        _titleColor = [titleColor retain];
        [self setNeedsDisplay];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (titleFont) {
        [_titleFont release];
        _titleFont = [titleFont retain];
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont *)font {
    if (font) {
        CFRelease(_ctFont);
        _ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL); 
        [self setNeedsDisplay];
    }
}


- (void)setCtFont:(CTFontRef)ctFont {
    if (ctFont) {
        CFRelease(_ctFont);
        CFRetain(ctFont);
        _ctFont = ctFont;
        [self setNeedsDisplay];
    }
}

- (void)setLeading:(CGFloat)leading {
    _leading = leading;
}


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setTextAligment:(UITextAlignment)textAligment {
    if (textAligment == UITextAlignmentCenter) {
        _textAligment = kCTCenterTextAlignment;
    } else if (textAligment == UITextAlignmentRight) {
        _textAligment = kCTRightTextAlignment;
    }
}

- (void)setText:(NSString *)text {
    [_text release];
    _text = [text copy];
    [self setNeedsDisplay];
}

- (void)updateFrame:(NSValue *)value {
    self.frame = [value CGRectValue];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1, -1);
    
    if (!_text) {
        return;
    }
    
    if (!_ctFont) {
        _ctFont = CTFontCreateWithName((CFStringRef)_font.fontName, _font.pointSize, NULL);
    }
    
    CTFontRef   tFont = _ctFont;
    if (_titleFont) {
        tFont = CTFontCreateWithName((CFStringRef)_titleFont.fontName, _titleFont.pointSize, NULL);
    }
    
    float textSize = CTFontGetSize(_ctFont);
    
    CTParagraphStyleSetting labelSettings[] = {
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &_leading},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &_leading},
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAligment},
        {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &textSize},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &textSize},
    };
    
    CTParagraphStyleRef labelStyle = CTParagraphStyleCreate(labelSettings, 5);
    
    CFStringRef keys[]          =       {kCTFontAttributeName, kCTForegroundColorAttributeName, kCTParagraphStyleAttributeName};
    CFTypeRef   values[]        =       { _ctFont, _textColor.CGColor, labelStyle };
    CFTypeRef   titleValues[]   =       { tFont, _titleColor.CGColor, labelStyle };

    
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFDictionaryRef tAttributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&titleValues, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFMutableAttributedStringRef text = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    if ([_title notEmpty]) {
        CFAttributedStringReplaceString(text, CFRangeMake(0, 0), (CFStringRef)_title);
        CFAttributedStringReplaceString(text, CFRangeMake([_title length], 0), (CFStringRef)_text);
        CFAttributedStringSetAttributes(text, CFRangeMake(0, [_title length]), tAttributes, false);
        CFAttributedStringSetAttributes(text, CFRangeMake([_title length], [_text length]), attributes, false);
    } else {
        CFAttributedStringReplaceString(text, CFRangeMake(0, 0), (CFStringRef)_text);
        CFAttributedStringSetAttributes(text, CFRangeMake(0, [_text length]), attributes, false);
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(text);
    
    CGSize framesize =  CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [_text length] + [_title length]), NULL, CGSizeMake(CGRectGetWidth(rect), CGFLOAT_MAX), NULL);
    CGRect frameRect;

    
    if (_verticalAligment == ELTextVerticalAligmentBottom) {
        frameRect = rect;
    } else if (_verticalAligment == ELTextVerticalAligmentCenter) {
        frameRect = CGRectMake(0, rintf(CGRectGetHeight(rect) / 2 - framesize.height / 2) - 3, CGRectGetWidth(rect), framesize.height);
    } else {
        frameRect = CGRectMake(0, CGRectGetHeight(rect) - framesize.height, CGRectGetWidth(rect), framesize.height);
    }
    
    self.renderedTextSize = framesize;
    
    CGPathRef path = CGPathCreateWithRect(frameRect, NULL);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_text length] + [_title length]), path, NULL);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, _shadowOffset, 0, _shadowColor.CGColor);
    
    CTFrameDraw(frame, context);
    
    CGContextRestoreGState(context);
    
    CFRelease(attributes);
    CFRelease(text);
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(labelStyle);
    CGPathRelease(path);
}

- (void)dealloc {
    CFRelease(_ctFont);
    [_title release];
    [_titleColor release];
    [_text release];
    [_textColor release];
    [_shadowColor release];
    [super dealloc];
}


@end
