//
//  ELBarButton.h
//  iOSKit
//
//  Created by Yarik Smirnov on 2/14/12.
//  Copyright (c) 2012 e-Legion ltd. All rights reserved.
//  

#import <UIKit/UIKit.h>

typedef enum {
    ELBarButtonModeLeft,
    ELBarButtonModeRight
} ELBarButtonMode;

@interface ELBarButton : UIButton {
@private
   id               _holder;
    NSInteger       _selfOffset;
}
@property (nonatomic, assign) id holder;
@property (nonatomic, assign) NSInteger selfOffset;
@property (nonatomic, assign) ELBarButtonMode mode; 
- (id)initWithImage:(UIImage *)image andHolder:(id)holder;

- (void)show;
- (void)hideWithRemove:(BOOL)remove;

@end
