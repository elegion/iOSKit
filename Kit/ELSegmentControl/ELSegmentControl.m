//
//  ElSegmentControl.m
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

- (id)initWithItems:(NSArray *)items {
    self = [super initWithFrame:YSRectMakeFromSize(180, 30)];
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
        }
    }
    return [_items objectAtIndex:index];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSInteger)segmentIndex forState:(UIControlState)state {
    NSMutableDictionary *itemDict = [self itemAtIndex:segmentIndex];
    UIButton *button = [itemDict objectForKey:_kELItemDictionaryKeyButton];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    if (state == UIControlStateNormal) {
        [itemDict setObject:image forKey:_kELItemDictionaryKeyNormalImage];
    } else {
        [itemDict setObject:image forKey:_kELItemDictionaryKeyActiveImage];
    }
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSInteger)segmentIndex {
    NSMutableDictionary *itemDict = [self itemAtIndex:segmentIndex];
    UIButton *button = [itemDict objectForKey:_kELItemDictionaryKeyButton];
    [button setTitle:title forState:UIControlStateNormal];
}

- (void)pressSegment:(id)segment {
    if (segment == _leftButton) {
        _selectedSegmentIndex = 0;
        [_leftButton setBackgroundImage:_leftActive forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:_rightNormal forState:UIControlStateNormal];
    } else {
        _selectedSegmentIndex = 1;
        [_leftButton setBackgroundImage:_leftNormal forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:_rightActive forState:UIControlStateNormal];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
    [_leftNormal release];
    [_rightNormal release];
    [_leftActive release];
    [_rightActive release];
    [_items release];
    [super dealloc];
}

@end
