//
//  ELPriceLine.h
//  iOSKit
//
//  Created by Yarik Smirnov on 6/25/12.
//  Copyright (c) 2012 Yarik Smirnov, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELCountLine : UIView {
@private
    NSString            *_title;
    NSString            *_price;
}

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger titleSize;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL isBold;

- (id)initWithTitle:(id)title andPrice:(NSNumber *)price;

- (void)setTitle:(id)title andPrice:(NSNumber *)price;

- (void)setPrice:(NSNumber *)number;

@end
