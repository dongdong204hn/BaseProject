//
//  NIPHorizontalLayout.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPHorizontalLayout.h"

@implementation NIPHorizontalLayout

- (CGSize)computeContentSizeForContent {
    CGSize needSize = CGSizeZero;
    for (NSInteger index=0;index<_layoutItems.count;index++) {
        NIPLayoutItem *layoutItem = _layoutItems[index];
        if (layoutItem.view.hidden
            ||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
            continue;
        }
        
        CGSize itemSize = CGSizeZero;
        if ([layoutItem.view isKindOfClass:[NIPLayoutBase class]]) {
            itemSize = [(NIPLayoutBase*)layoutItem.view neededSizeForContent];
        } else {
            itemSize = layoutItem.view.frame.size;
        }
        needSize.width += itemSize.width;
        needSize.height = MAX(needSize.height, itemSize.height);

        if (index!=0) {
            needSize.width += layoutItem.spacing;
        }
    }
    needSize.width += self.contentInsets.left;
    needSize.width += self.contentInsets.right;
    needSize.height += self.contentInsets.top;
    needSize.height += self.contentInsets.bottom;
    return needSize;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = self.contentInsets.left;
    CGFloat withBalance = self.bounds.size.width-[self computeContentSizeForContent].width;
    for (NSInteger index=0;index<_layoutItems.count;index++) {
        NIPLayoutItem *layoutItem  = _layoutItems[index];
        if (layoutItem.view.hidden
            ||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
            continue;
        }
        if (index>0) {
            x += layoutItem.spacing;
        }
        CGRect frame = layoutItem.view.frame;
        frame.origin.x = x;
        if (layoutItem.layoutOptionMask&ZBLayoutOptionAutoResize) {
            frame.size.width += withBalance;
            withBalance = 0;
        } else if (layoutItem.layoutOptionMask&ZBLayoutOptionAutoResizeShrink&&withBalance<.0) {
            frame.size.width += withBalance;
            withBalance = 0;
        } else if (layoutItem.layoutOptionMask&ZBLayoutOptionAutoResizeExpand&&withBalance>.0) {
            frame.size.width += withBalance;
            withBalance = 0;
        }
        
         if (layoutItem.layoutOptionMask&ZBLayoutOptionAlignmentCenter) {
             frame.origin.y = (self.bounds.size.height-frame.size.height)/2;
         } else if (layoutItem.layoutOptionMask&ZBLayoutOptionAlignmentBottom) {
             frame.origin.y = self.bounds.size.height-frame.size.height-self.contentInsets.bottom;
         } else {
             frame.origin.y = self.contentInsets.top;
         }
        layoutItem.view.frame = frame;
        x += frame.size.width;
    }
    
    if (withBalance>0) {
        for (NSInteger index=0;index<_layoutItems.count;index++) {
            NIPLayoutItem *layoutItem  = _layoutItems[index];
            if (layoutItem.view.hidden
                ||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
                continue;
            }
            if (self.contentLayoutOption&ZBLayoutOptionAlignmentCenter) {
                layoutItem.view.left = layoutItem.view.left+withBalance/2;
            } else if (self.contentLayoutOption&ZBLayoutOptionAlignmentRight) {
                layoutItem.view.left = layoutItem.view.left+withBalance;            
            }
        }
    }
}


@end
