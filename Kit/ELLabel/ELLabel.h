//
//  ELLabel.h
//  iOSKit
//
//  Created by Yarik Smirnov on 6/28/12.
//  Copyright (c) 2012 Yarik Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

enum {
    ELTextVerticalAligmentBottom,
    ELTextVerticalAligmentTop,
    ELTextVerticalAligmentCenter,
};
typedef int ELTextVerticalAligment;

@interface ELLabel : UIView {
@private
    NSString        *_text;
    UIColor         *_textColor;
    CTTextAlignment _textAligment;
    CGFloat         _leading;
    CGFloat         _textSize;
    UIColor         *_shadowColor;
    CGSize          _shadowOffset;

}
@property (nonatomic, assign) CGFloat leading; //interlines distance
@property (nonatomic, strong) UIFont  *font;
@property (nonatomic, assign) CTFontRef ctFont;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) UITextAlignment textAligment;
@property (nonatomic, assign) ELTextVerticalAligment verticalAligment;
@property (nonatomic, assign) CGSize  shadowOffset;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, assign) CGSize  renderedTextSize;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;


@end
