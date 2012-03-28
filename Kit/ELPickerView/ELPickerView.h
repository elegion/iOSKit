//
//  ELPickerView.h
//  
//
//  Created by Yarik Smirnov on 12/12/11.
//  Copyright (c) 2011 e-Legion ltd. All rights reserved.
//

@class ELPickerView, ELPickerCenter;
@protocol ELPickerViewDelegate <NSObject>

- (void)pickerView:(ELPickerView *)pickerView didSelectValue:(NSInteger)value;

- (void)pickerViewWillBeginScrollingAnimation;
- (void)pickerViewDidiEndScrollingAnimation;

@end

typedef enum {
    ELPickerViewStyleSmall,
    ELPickerViewStyleLarge
} ELPickerViewStyle;

@interface ELPickerView : UIView {
@private
    ELPickerCenter              *_center;
    UIImageView                 *_graphic;
    UIImageView                 *_edges;
    
    UIScrollView                *_scrollView;
    id<UIScrollViewDelegate>    _forwardResponder;
    NSRange                     _range;
    NSInteger                   _currentSelection;
    id<ELPickerViewDelegate>    _delegate;
    NSArray                     *_graphicsNames;
}
@property(nonatomic, assign) id<ELPickerViewDelegate> delegate;
@property(nonatomic, retain) NSArray *graphicImagesNames; // Array of 3 strings with names of images for: center panel, center panel edges, shadows of roll.
@property(nonatomic, assign) ELPickerViewStyle pickerStyle;

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame;

- (id)initWithRange:(NSRange)range andFrame:(CGRect)frame andStyle:(ELPickerViewStyle)style;

- (void)setRightPosition;

- (void)setSelection:(NSInteger)shiftFromLocation;

@end
