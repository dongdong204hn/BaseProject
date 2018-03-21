//
//  NIPScrollContainer.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPScrollContainer.h"

@implementation NIPScrollContainer {
    NIPLayoutBase *_layout;
    NSMutableArray *_childViews;
}

- (NIPLayoutBase*)layout {
    [self creatLayoutIfNeeded];
    return _layout;
}

- (NSInteger)childViewCount {
    return _layout.layoutableSubviewCount;
}

- (void)creatLayoutIfNeeded {
    if (!_layout) {
        _layout = [NIPLayoutBase layoutOfType:self.layoutType];
        _layout.frame = self.bounds;
        [self addSubview:_layout];
        
        _childViews = [NSMutableArray array];
    }
}

- (void)addChildView:(UIView *)childView {
    [self addChildView:childView withSpace:0];
}

- (void)addChildView:(UIView *)childView withSpace:(CGFloat)space {
    [self addChildView:childView withSpace:space option:ZBLayoutOptionAlignmentLeft];
}

- (void)addChildView:(UIView *)childView withSpace:(CGFloat)space option:(ZBLayoutOptionMask)options {
    [self creatLayoutIfNeeded];
    
    [_layout addSubview:childView withSpace:space option:options];
    [_childViews addObject:childView];
    [self setNeedsLayout];
}

- (void)addChildViews:(NSArray *)childViews {
    for (UIView *childView in childViews) {
        [self addChildView:childView];
    }
}

- (void)clearChildViews {
    [_layout removeAllSubViews];
    [_childViews removeAllObjects];
    [self setNeedsLayout];
}

- (void)childViewChanged:(UIView*)childView {
    if ([_childViews containsObject:childView]) {
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [_layout resizeToContent];
    [_layout layoutSubviews];
    self.contentSize = CGSizeMake(MAX(self.size.width,_layout.size.width),
                                  MAX(self.size.height,_layout.size.height));
}

@end
