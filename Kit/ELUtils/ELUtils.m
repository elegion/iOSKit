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

NSString * ELMaskedPhoneNumber(NSString *phone) {
    NSMutableString *result = [NSMutableString string];
    BOOL hasPlus = NO;
    if ([phone rangeOfString:@"+"].length > 0) {
        hasPlus = YES;
        phone = [phone substringFromIndex:1];
    }
    for (int i = 0; i < [phone length]; i ++) {
        if (i == 1 && (hasPlus || [phone length] > 7)) {
            [result appendString:@" ("];
        }
        if ((i == 3 || i == 5)&& !hasPlus && [phone length] < 8) {
            [result appendString:@"-"];
        }
        if (i == 4 && (hasPlus || [phone length] > 7)) {
            [result appendString:@") "];
        }
        if ((i == 7 || i == 9) && (hasPlus || [phone length] > 7)) {
            [result appendString:@"-"];
        }
        [result appendString:[phone substringWithRange:NSMakeRange(i, 1)]];
    }
    if ([phone length] < 5 && [phone length] > 1 && hasPlus) {
        for (int j = 0; j < 4 - [phone length]; j++) {
            [result appendString:@" "];
        }
        [result appendString:@")"];
    }
    if (hasPlus) {
        [result insertString:@"+" atIndex:0];
    }
    return result;
}

NSString * ELStringByGroupingNumber(NSNumber *number) {
    static NSNumberFormatter *nf = nil;
    if (!nf) {
        nf = [[NSNumberFormatter alloc] init];
        [nf setGroupingSize:3];
        [nf setGroupingSeparator:@" "];
        [nf setUsesGroupingSeparator:YES];
        [nf setMaximumFractionDigits:2];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setDecimalSeparator:@","];
    }
    
    return [nf stringFromNumber:number];
}


@implementation UIColor (HexademicalColors)

+ (UIColor *)colorFromHex:(NSUInteger)hex alpha:(CGFloat)alphaInPercentage {
    return ELColorGetWithHexAndAlpha(hex, alphaInPercentage);
}

+ (UIColor *)colorFromHex:(NSUInteger)hexademical {
    return [UIColor colorFromHex:hexademical alpha:100];
}

@end

@implementation NSString (Utils)

- (BOOL)notEmpty {
    return [self length] != 0;
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