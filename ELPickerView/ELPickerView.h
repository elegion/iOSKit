//
//  ELPickerView.h
//  
//
//  Created by Yarik Smirnov on 12/12/11.
//  Copyright (c) 2011 e-Legion ltd. All rights reserved.
//

@class ELPickerView;
@protocol ELPickerViewDelegate <NSObject>

- (void)pickerView:(ELPickerView *)pickerView didSelectValue:(NSInteger)value;

- (void)pickerViewWillBeginScrollingAnimation;
- (void)pickerViewDidiEndScrollingAnimation;

@end

@interface ELPickerView : UIView {
@private
    UIScrollView                *_scrollView;
    id<UIScrollViewDelegate>    _forwardResponder;
    NSRange                     _range;
    NSInteger                   _currentSelection;
    id<ELPickerViewDelegate>    _delegate;
    NSArray                     *_graphicsNames;
}
@property(nonatomic, assign) id<ELPickerViewDelegate> delegate;
@property(nonatomic, retain) NSArray *graphicImagesNames; // Array of 3 strings with names of images for: center panel, center panel edges, shadows of roll.

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame;

- (void)setRightPosition;

- (void)setSelection:(NSInteger)shiftFromLocation;

@end
