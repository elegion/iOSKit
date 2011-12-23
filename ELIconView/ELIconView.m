//
//  ELIconView.m
//  ArtFlora
//
//  Created by Yarik Smirnov on 23.12.11.
//  Copyright (c) 2011 e-Legion Ltd. All rights reserved.
//

#import "ELIconView.h"
#import <QuartzCore/QuartzCore.h>
#import "YSDrawingKit.h"

@implementation ELIconView

- (id)initWithIcon:(UIImage *)icon {
    self = [super init];
    if (self) {
        self.opaque = NO;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6.0;
        
        _iconImage = icon.CGImage;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CGContextClearRect(context, self.bounds);
    
    CGMutablePathRef clipPath = CGPathCreateMutable();
    YSPathAddRoundedStrechedRect(clipPath, 9.0, rect);
    CGContextSetLineWidth(context, 9.0);
    CGContextAddPath(context, clipPath);
    CGPathRelease(clipPath);
        
    CGContextSaveGState(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), _iconImage);
    CGImageRef roundedImage = CGBitmapContextCreateImage(context);
    CGContextRestoreGState(context);
    CGContextClearRect(context, rect);
    
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(0, 1), 2.0);
    CGContextDrawImage(context, CGRectMake(2, 2, self.bounds.size.width - 4, self.bounds.size.height - 4), roundedImage);
    CGContextRestoreGState(context);
    
    CGImageRelease(roundedImage);
}

- (void)dealloc {
    CGImageRelease(_iconImage);
    [super dealloc];
}

@end
