//
//  YSPickerView.h
//  
//
//  Created by Yarik Smirnov on 12/12/11.
//  Copyright (c) 2011 Yarik Smirnov. All rights reserved.
//

@class YSPickerView;
@protocol YSPickerViewDelegate <NSObject>

- (void)pickerView:(YSPickerView *)pickerView didSelectValue:(NSInteger)value;

- (void)pickerViewWillBeginScrollingAnimation;
- (void)pickerViewDidiEndScrollingAnimation;

@end

@interface YSPickerView : UIView {
@private
    UIScrollView *_scrollView;
    id<UIScrollViewDelegate> _forwardResponder;
    NSRange _range;
    NSInteger _currentSelection;
    id<YSPickerViewDelegate> _delegate;
}
@property(nonatomic, assign) id<YSPickerViewDelegate> delegate;

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame;

- (void)setRightPosition;

- (void)setSelection:(NSInteger)shiftFromLocation;

@end
