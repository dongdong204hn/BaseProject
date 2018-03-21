//
//  NIPGridLayout.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPGridLayout.h"

@implementation NIPGridLayout

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.columnCount = 2;
    }
    return self;
}

- (CGSize)neededSizeForContent {
    CGFloat totalHeight = 0;
    CGFloat totalWidth = 0;
    if (_layoutItems.count>0) {
        NSInteger index=0;
        while (index<_layoutItems.count) {
            NSInteger nextRowHeadIndex = MIN(_layoutItems.count, (index+self.columnCount));
            CGFloat rowHeight = 0.0;
            CGFloat rowWidth = 0.0;
            while (index<nextRowHeadIndex) {
                NIPLayoutItem *layoutItem  = _layoutItems[index];
                if (layoutItem.view.hidden||layoutItem.layoutOptionMask&ZBLayoutOptionDontLayout) {
                    continue;
                }
                CGSize itemSize = layoutItem.view.frame.size;
                if ([layoutItem.view isKindOfClass:[NIPLayoutBase class]]) {
                    itemSize = [(NIPLayoutBase*)layoutItem.view neededSizeForContent];
                }
                rowHeight = MAX(rowHeight, itemSize.height);
                rowWidth += itemSize.width;
                index++;
            }
            index = nextRowHeadIndex;
            totalHeight += rowHeight+ ((index==_layoutItems.count)?.0:self.rowSpace);
            totalWidth = MAX(totalWidth, rowWidth+(self.columnCount-1)*self.columnSpace);
        }

        totalHeight += self.contentInsets.top;
        totalHeight += self.contentInsets.bottom;
        
        totalWidth += self.contentInsets.left;
        totalWidth += self.contentInsets.right;
    }
    CGSize neededSize = self.frame.size;
    neededSize.height = MAX(self.minimumSize.height,totalHeight);
    neededSize.width = MAX(self.minimumSize.width,totalWidth);
    return neededSize;
}

- (void)setColumnCount:(NSInteger)columnCount {
    _columnCount = columnCount;
    if (_columnCount==0) {
        _columnCount = 1;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (_layoutItems.count>0) {
        CGFloat y = self.contentInsets.top;
        NSInteger index=0;
        while (index<_layoutItems.count) {
            NSInteger nextRowHeadIndex = MIN(_layoutItems.count, (index+self.columnCount));
            CGFloat rowHeight = 0.0;
            CGFloat x = self.contentInsets.left;
            while (index<nextRowHeadIndex) {
                NIPLayoutItem *layoutItem  = _layoutItems[index];
                layoutItem.view.topLeft = CGPointMake(x, y);
                x += self.columnSpace+layoutItem.view.width;
                rowHeight = MAX(rowHeight, layoutItem.view.height+self.rowSpace);
                index++;
            }
            y+= rowHeight;
            index = nextRowHeadIndex;
        }
    }
}


@end
