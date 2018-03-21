//
//  NIPScrollContainer.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#include "NIPLayoutBase.h"

/**
 *  NIPScrollContainer是一个结合layout的容器类
 */
@interface NIPScrollContainer : UIScrollView
@property(nonatomic) ZBLayoutType layoutType;
@property(nonatomic,readonly) NIPLayoutBase *layout;
@property(nonatomic,readonly) NSInteger childViewCount;

- (void)childViewChanged:(UIView*)childView;
- (void)addChildView:(UIView *)childView;
- (void)addChildView:(UIView *)childView withSpace:(CGFloat)space;
- (void)addChildView:(UIView *)childView withSpace:(CGFloat)space option:(ZBLayoutOptionMask)options;
- (void)addChildViews:(NSArray *)childViews;
- (void)clearChildViews;
@end
