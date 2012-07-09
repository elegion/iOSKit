//
//  UIView+ELCoping.h
//  iOSKit
//
//  Created by Yarik Smirnov on 7/9/12.
//  Copyright (c) 2012 e-legion ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSKit.h"

@interface UIView (NSCopying)  <NSCopying>

@end

@interface UIImage (NSCopying) 

+ (UIImage *)imageWithImage:(UIImage *)image;

@end

@interface UILabel (NSCopying) <NSCopying>

@end

@interface  ELLabel (NSCopying) <NSCopying>

@end
