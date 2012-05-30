//
//  ELSegmentControl.m
//  iOSKit
//
//  Created by Yarik Smirnov on 2/13/12.
//  Copyright (c) 2012 e-Legion ltd. All rights reserved.
//

#import "ELSegmentControl.h"
#import "ELUtils.h"
#import "YSDrawingKit.h"

@interface ELSegmentControl (Internal)

- (void)pressSegment:(id)segment;

- (NSMutableDictionary *)itemAtIndex:(NSInteger)index;

@end

static NSString * const _kELItemDictionaryKeyButton         =       @"__button";
static NSString * const _kELItemDictionaryKeyNormalImage    =       @"__image";
static NSString * const _kELItemDictionaryKeyActiveImage    =       @"__active_image";

@implementation ELSegmentControl
@synthesize selectedSegmentIndex = _selectedSegmentIndex;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor;
@synthesize titleShadow = _titleShadow;
@synthesize shadowOffset = _shadowOffset;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedSegmentIndex = 0;
        
        _titleColor = [UIColor whiteColor];
        _titleFont = ELFontGetHelveticaNeue(12, ELFontStyleBold);
        _titleShadow = [UIColor blackColor];
        _shadowOffset = CGSizeMake(0, -1);
    }
    return self;
}

- (NSMutableDictionary *)itemAtIndex:(NSInteger)index {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    int diff = (index + 1) - [_items count];
    if (diff > 0) {
        CGFloat oneItemWidth = rintf(CGRectGetWidth(self.bounds) / ([_items count] + diff));
        for (int i = 0; i < [_items count]; i++) {
            UIButton *btn = [[_items objectAtIndex:i] objectForKey:_kELItemDictionaryKeyButton];
            btn.frame = CGRectMake(i * oneItemWidth, 0, oneItemWidth, CGRectGetHeight(self.bounds));
        }
        for (int d = 0; d < diff; d++) {
            NSMutableDictionary *itemDict = [NSMutableDictionary dictionary];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(([_items count] + d) * oneItemWidth, 0, oneItemWidth, CGRectGetHeight(self.bounds))];
            [button setTitleShadowColor:_titleShadow forState:UIControlStateNormal];
            button.titleLabel.font = _titleFont;
            button.titleLabel.textColor = _titleColor;
            button.titleLabel.shadowOffset = _shadowOffset;
            button.adjustsImageWhenHighlighted = NO;
            [button addTarget:self action:@selector(pressSegment:) forControlEvents:UIControlEventTouchDown];
            
            [self addSubview:button];
            [itemDict setObject:button forKey:_kELItemDictionaryKeyButton];
            [_items addObject:itemDict];
            
            [button release];
            
            if (index == 0) {
                _selectedItem = button;
            }
        }
    }
    return [_items objectAtIndex:index];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSInteger)segmentIndex forState:(UIControlState)state {
    if (image) {
        NSMutableDictionary *itemDict = [self itemAtIndex:segmentIndex];
        UIButton *button = [itemDict objectForKey:_kELItemDictionaryKeyButton];
        if (state == UIControlStateNormal) {
            [itemDict setObject:image forKey:_kELItemDictionaryKeyNormalImage];
            [button setBackgroundImage:image forState:UIControlStateNormal];
        } else {
            [itemDict setObject:image forKey:_kELItemDictionaryKeyActiveImage];
            if (_selectedSegmentIndex == [_items indexOfObject:itemDict]) {
                [button setBackgroundImage:image forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSInteger)segmentIndex {
    if (title) {
        NSMutableDictionary *itemDict = [self itemAtIndex:segmentIndex];
        UIButton *button = [itemDict objectForKey:_kELItemDictionaryKeyButton];
        [button setTitle:title forState:UIControlStateNormal];
    }
}

- (void)pressSegment:(id)segment {
    if (segment == _selectedItem) {
        return;
    }
    for (NSMutableDictionary *item in _items) {
        UIButton *btn = [item objectForKey:_kELItemDictionaryKeyButton];
        if (btn == segment) {
            _selectedItem = btn;
            self.selectedSegmentIndex = [_items indexOfObject:item];
            [btn setBackgroundImage:[item objectForKey:_kELItemDictionaryKeyActiveImage] forState:UIControlStateNormal];
        } else {
            [btn setBackgroundImage:[item objectForKey:_kELItemDictionaryKeyNormalImage] forState:UIControlStateNormal];
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
    [_items release];
    [super dealloc];
}

@end
