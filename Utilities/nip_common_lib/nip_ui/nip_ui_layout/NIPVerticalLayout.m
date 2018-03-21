//
//  NIPVerticalLayout.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPVerticalLayout.h"

@implementation NIPVerticalLayout

- (CGSize)neededSizeForContent {
    CGFloat totalHeight=0;
    if (_layoutItems.count>0) {
        BOOL firstItemNeedsLayout = YES;
        for (NSInteger index=0;index<_layoutItems.count;index++) {
            NIPLayoutItem *layoutItem = _layoutItems[index];
            if (layoutItem.view.hidden||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
                continue;
            }
            if ([layoutItem.view isKindOfClass:[NIPLayoutBase class]]) {
                totalHeight += [(NIPLayoutBase*)layoutItem.view neededSizeForContent].height;
            } else {
                totalHeight += layoutItem.view.frame.size.height;
            }            
            if (!firstItemNeedsLayout) {
                totalHeight += layoutItem.spacing;
            }
            firstItemNeedsLayout = NO;
        }
        if (!firstItemNeedsLayout) { //has visible layoutItem
            totalHeight += self.contentInsets.top;
            totalHeight += self.contentInsets.bottom;
        }
    }
    CGSize needSize = self.frame.size;
    needSize.height = MAX(totalHeight,self.minimumSize.height);
    return needSize;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat y = self.contentInsets.top;
    
    CGFloat extraSpace = self.bounds.size.height-self.contentInsets.top-self.contentInsets.bottom;
    NSInteger autoRisizableItemCount = 0;
    BOOL firstItemNeedsLayout = YES;
    for (NSInteger index=0;index<_layoutItems.count;index++) {        
        NIPLayoutItem *layoutItem  = _layoutItems[index];
        if (layoutItem.view.hidden
            ||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
            continue;
        }
        if (!firstItemNeedsLayout) {
            extraSpace -= layoutItem.spacing;
        }
        if (layoutItem.layoutOptionMask&ZBLayoutOptionAutoResize) {
            autoRisizableItemCount ++;
            continue;
        }
        CGRect frame = layoutItem.view.frame;
        extraSpace -= frame.size.height;
        firstItemNeedsLayout = NO;
    }

    if (autoRisizableItemCount>0) {
        extraSpace = extraSpace/autoRisizableItemCount;
    }
    
    
    firstItemNeedsLayout = YES;
    for (NSInteger index=0;index<_layoutItems.count;index++) {        
        NIPLayoutItem *layoutItem  = _layoutItems[index];
        if (layoutItem.view.hidden||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
            continue;
        }     
        if (!firstItemNeedsLayout) {
            y += layoutItem.spacing;
        }
        
        CGRect frame = layoutItem.view.frame;
        frame.origin.y = y;
        if (layoutItem.layoutOptionMask&ZBLayoutOptionAutoResize) {
            frame.size.height = extraSpace;
        }
        if (layoutItem.layoutOptionMask&ZBLayoutOptionAlignmentRight) {
            frame.origin.x = self.bounds.size.width-frame.size.width-self.contentInsets.right;
        } else if (layoutItem.layoutOptionMask&ZBLayoutOptionAlignmentCenter) {
            frame.origin.x = (self.bounds.size.width-frame.size.width)/2;
        } else {
            frame.origin.x = self.contentInsets.left;
        }
        layoutItem.view.frame = frame;
        y += frame.size.height;
        firstItemNeedsLayout = NO;
    }
}

@end
