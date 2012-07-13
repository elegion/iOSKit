//
//  UIView+ELCoping.m
//  iOSKit
//
//  Created by Yarik Smirnov on 7/9/12.
//  Copyright (c) 2012 e-legion ltd. All rights reserved.
//

#import "UIView+NSCopying.h"

@implementation UIView (NSCopying)

- (id)copy {
    
    UIView *newView = [[[self class] alloc] initWithFrame:self.frame];
    newView.backgroundColor = self.backgroundColor;
    newView.opaque = self.opaque;
    newView.autoresizingMask = self.autoresizingMask;
    newView.contentMode = self.contentMode;
    newView.clipsToBounds = self.clipsToBounds;
    newView.tag = self.tag;
    newView.userInteractionEnabled = self.userInteractionEnabled;
    
    return newView;
}

@end

@implementation UIImage (NSCopying)



@end

@implementation UILabel (NSCopying)

- (id)copy {
    
    UILabel *newLabel = [super copy];
    newLabel.font = self.font;
    newLabel.text = self.text;
    newLabel.textColor = self.textColor;
    newLabel.highlighted = self.highlighted;
    newLabel.highlightedTextColor = self.highlightedTextColor;
    newLabel.textAlignment = self.textAlignment;
    newLabel.shadowColor = self.shadowColor;
    newLabel.shadowOffset = self.shadowOffset;
    newLabel.lineBreakMode = self.lineBreakMode;
    newLabel.enabled = self.enabled;
    newLabel.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth;
    newLabel.numberOfLines = self.numberOfLines;
    newLabel.baselineAdjustment = self.baselineAdjustment;
    
    return newLabel;
}

@end

@implementation ELLabel (NSCopying)

- (id)copy {
    
    ELLabel *newLabel = [super copy];
    newLabel.text = self.text;
    newLabel.leading = self.leading;
    newLabel.textAligment = self.textAligment;
    newLabel.verticalAligment = self.verticalAligment;
    newLabel.ctFont = self.ctFont;
    newLabel.shadowColor = self.shadowColor;
    newLabel.shadowOffset = self.shadowOffset;
    
    newLabel.title = self.title;
    newLabel.titleColor = self.titleColor;
    newLabel.titleFont = self.titleFont;
    
    return newLabel;
}

@end
