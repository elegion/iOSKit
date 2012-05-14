//
//  ELUtils.h
//  iOSKit
//
//  Created by Yarik Smirnov on 3/28/12.
//  Copyright (c) 2012 e-legion ltd. All rights reserved.
//

#ifndef iOSKit_ELUtils_h
#define iOSKit_ELUtils_h

#import <UIKit/UIKit.h>
#import "YSFonts.h"

enum {
    ELFontFamilyNameMarkerFelt = kYSFontFamilyNameMarkerFelt,
    ELFontFamilyNameTrebuchetMS = kYSFontFamilyNameTrebuchetMS,
    ELFontFamilyNameArial = kYSFontFamilyNameArial,
    ELFontFamilyNameMarion = kYSFontFamilyNameMarion,
    ELFontFamilyNameCochin = kYSFontFamilyNameCochin,
    ELFontFamilyNameVerdana = kYSFontFamilyNameVerdana,
    ELFontFamilyNameCourier = kYSFontFamilyNameCourier,
    ELFontFamilyNameHelvetica = kYSFontFamilyNameHelvetica,
    ELFontFamilyNameTimesNewRoman = kYSFontFamilyNameTimesNewRoman,
    ELFontFamilyNameFutura = kYSFontFamilyNameFutura,
    ELFontFamilyNameAmericanTypewriter = kYSFontFamilyNameAmericanTypewriter,
    ELFontFamilyNameGeorgia = kYSFontFamilyNameGeorgia,
    ELFontFamilyNameHelveticaNeue = kYSFontFamilyNameHelveticaNeue,
    ELFontFamilyNameGillSans = kYSFontFamilyNameGillSans,
    ELFontFamilyNameCourierNew = kYSFontFamilyNameCourierNew,
};
typedef unsigned int ELFontFamilyName;

enum {
    ELFontStyleCondensedLight = kYSFontStyleCondensedLight,
    ELFontStyleLight = kYSFontStyleLight,
    ELFontStyleMedium = kYSFontStyleMedium,
    ELFontStyleRegular = kYSFontStyleRegular,
    ELFontStyleUltraLight = kYSFontStyleUltraLight,
    ELFontStyleItalic = kYSFontStyleItalic,
    ELFontStyleLightItalic = kYSFontStyleLightItalic,
    ELFontStyleUltraLightItalic = kYSFontStyleUltraLightItalic,
    ELFontStyleBold = kYSFontStyleBold,
    ELFontStyleBoldItalic = kYSFontStyleBoldItalic,
    ELFontStyleCondensedBlack = kYSFontStyleCondensedBlack,
    ELFontStyleCondensedBold = kYSFontStyleCondensedBold,
};
typedef unsigned int ELFontStyle;

UIFont * ELFontGetFromFamilyName(ELFontFamilyName familyName, ELFontStyle style, CGFloat pointSize);

UIFont * ELFontGetHelveticaNeue(CGFloat pointSize, ELFontStyle fontStyle);

UIColor * ELColorGetWithHex(NSUInteger hexColor);

UIColor * ELColorGetWithHexAndAlpha(NSUInteger hexColor, CGFloat alphaInPercents);

NSString * ELStringGetByFilteringPhone(NSString *phone);

@interface UIColor (HexademicalColors)

+ (UIColor *)colorFromHex:(NSUInteger)hex alpha:(CGFloat)alphaInPercentage;

+ (UIColor *)colorFromHex:(NSUInteger)hexademical;

@end

UIImage * ELImageGetStretchable(NSString *name, CGFloat leftCap, CGFloat topCap);

#endif
