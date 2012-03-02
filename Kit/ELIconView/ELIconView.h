//
//  ELIconView.h
//  iOSKit
//
//  Created by Yarik Smirnov on 23.12.11.
//  Copyright (c) 2011 e-Legion Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELIconView : UIView {
    CGImageRef _iconImage;
}

- (id)initWithIcon:(UIImage *)icon;

@end

