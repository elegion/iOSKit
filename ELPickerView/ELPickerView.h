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
    UIScrollView *_scrollView;
    id<UIScrollViewDelegate> _forwardResponder;
    NSRange _range;
    NSInteger _currentSelection;
    id<ELPickerViewDelegate> _delegate;
}
@property(nonatomic, assign) id<ELPickerViewDelegate> delegate;

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame;

- (void)setRightPosition;

- (void)setSelection:(NSInteger)shiftFromLocation;

@end
