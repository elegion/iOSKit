//
//  ELUtils.m
//  iOSKit
//
//  Created by Yarik Smirnov on 3/28/12.
//  Copyright (c) 2012 e-legion ltd. All rights reserved.
//

#import "ELUtils.h"
#import "YSGraphics.h"

UIFont * ELFontGetFromFamilyName(ELFontFamilyName familyName, ELFontStyle style, CGFloat pointSize) {
    CTFontRef ctFont = YSFontCreateFromWithNameAndStyle(familyName, style, pointSize);
    CFStringRef name = CTFontCopyPostScriptName(ctFont);
    
    UIFont * font = [UIFont fontWithName:(NSString *)name size:pointSize];
    if (!font) {
        ELFontStyle replaceStyle;
        switch (style) {
            case ELFontStyleMedium:
                replaceStyle = ELFontStyleRegular;
                break;
            case ELFontStyleLight:
                replaceStyle = ELFontStyleRegular;
                break;
            case ELFontStyleCondensedBold:
                replaceStyle = ELFontStyleBold;
                break;
            default:
                break;
        }
        font = ELFontGetFromFamilyName(familyName, replaceStyle, pointSize);
    }
    
    CFRelease(ctFont);
    CFRelease(name);
    
    return font;
}

UIFont * ELFontGetHelveticaNeue(CGFloat pointSize, ELFontStyle fontStyle) {
    return ELFontGetFromFamilyName(ELFontFamilyNameHelveticaNeue, fontStyle, pointSize);
}

UIColor * ELColorGetWithHex(NSUInteger hexColor) {
    return ELColorGetWithHexAndAlpha(hexColor, 100);
}

UIColor * ELColorGetWithHexAndAlpha(NSUInteger hexColor, CGFloat alphaInPercents) {
    unsigned int hexColorWithAlpha = (unsigned int)((hexColor << 8) | (unsigned int)rintf((alphaInPercents / 100) * 255.0));
    CGColorRef graphicColor = YSColorCreateWithRGBA(hexColorWithAlpha);
    
    UIColor *color = [UIColor colorWithCGColor:graphicColor];
    
    CGColorRelease(graphicColor);
    
    return color;
}

NSString * ELStringGetByFilteringPhone(NSString *phone) {
    return [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"+0123456789-()"] invertedSet]] componentsJoinedByString:@""];
}


@implementation UIColor (HexademicalColors)

+ (UIColor *)colorFromHex:(NSUInteger)hex alpha:(CGFloat)alphaInPercentage {
    return ELColorGetWithHexAndAlpha(hex, alphaInPercentage);
}

+ (UIColor *)colorFromHex:(NSUInteger)hexademical {
    return [UIColor colorFromHex:hexademical alpha:100];
}

@end


UIImage * ELImageGetStretchable(NSString *name, CGFloat leftCap, CGFloat topCap) {
    return [[UIImage imageNamed:name] stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

@implementation NSString (iOSKit)

- (BOOL)isEmpty {
    if ([self length] == 0) {
        return YES;
    }
    return NO;
}

@end