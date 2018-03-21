//
//  NIPSortSegmentView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSortSegmentView.h"

@implementation NIPSortSegmentCell
- (void)renderCell {
    
}
@end

@implementation NIPSortSegmentView {
    NSMutableArray *_sepViews;
}

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.cellClass =  [NIPSortSegmentCell class];
        _segmentCells = [NSMutableArray array];
        _sepViews = [NSMutableArray array];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segmentTapped:)]];
        _selectedIndex = NSNotFound;
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setSegmentTitles:(NSArray *)segmentTitles {
    _segmentTitles = segmentTitles;
    _selectedIndex = NSNotFound;
    [self resetSegmentTitles];
}

- (void)resetSegmentTitles {
    for (NIPView *cell in _segmentCells) {
        [cell removeFromSuperview];
    }
    [_segmentCells removeAllObjects];
    
    for (NSString *title in self.segmentTitles) {
        [self addSegmentTitle:title];
    }
}

- (void)addSegmentTitle:(NSString*)title {
    NIPSortSegmentCell *cell = [[self.cellClass alloc] initWithFrame:CGRectZero];
    cell.descending = NO;
    cell.title = title;
    cell.segmentIndex = _segmentCells.count;
    [_contentView addSubview:cell];
    [_segmentCells addObject:cell];
    if (self.selectedIndex==NSNotFound) {
        self.selectedIndex = 0;
    }
    [cell renderCell];
    [self setNeedsLayout];
}

-(BOOL)isSegmentDecending:(NSUInteger)index {
    return [[_segmentCells objectAtIndex:index] descending];
}

-(void)segmentTapped:(UITapGestureRecognizer*)sender {
    if (sender.state!=UIGestureRecognizerStateRecognized) {
        return;
    }
    NSUInteger index = 0;
    for (NIPSortSegmentCell *cellView in _segmentCells) {
        if (CGRectContainsPoint(cellView.bounds, [sender locationInView:cellView])) {
            if (self.selectedIndex!=index) {
                self.selectedIndex = index;
            } else {
                cellView.descending = ! cellView.descending;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            break;
        }
        index ++;
    }
}

-(void)setSelectedIndex:(NSUInteger)highlightIndex {
    if (_selectedIndex!=highlightIndex) {
        BOOL shouldSendActions = NO;
        if (_selectedIndex!=NSNotFound) {
            shouldSendActions = YES;
            
            NIPSortSegmentCell *cell = [_segmentCells objectAtIndex:_selectedIndex];
            cell.selected = NO;
            [cell renderCell];
        }
        
        _selectedIndex = highlightIndex;
        
        NIPSortSegmentCell *cell = [_segmentCells objectAtIndex:_selectedIndex];
        cell.selected = YES;
        [cell renderCell];
        
        if (shouldSendActions) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}



-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;
    if ([_segmentCells count]==0) {
        return;
    }
    _backgroundView.frame = rect;
    
    while (_sepViews.count<_segmentCells.count-1) {
        UIView *sep = [[UIView alloc] init];
        sep.backgroundColor = self.segmentSepColor;
        [_sepViews addObject:sep];
        [_contentView addSubview:sep];
    }
    while (_sepViews.count>_segmentCells.count-1) {
        [_sepViews.lastObject removeFromSuperview];
        [_sepViews removeLastObject];
    }
    
    
    _contentView.frame = CGRectMake(rect.origin.x+self.edgeInsets.left,
                      rect.origin.y+self.edgeInsets.top,
                      rect.size.width-self.edgeInsets.left-self.edgeInsets.right,
                      rect.size.height-self.edgeInsets.top-self.edgeInsets.bottom);
    
    CGFloat segWidth = (_contentView.size.width-self.segmentSepWith*(_segmentCells.count-1))/[_segmentCells count];
    CGFloat x = 0;
    CGFloat y = 0;
    for (int i=0; i<[_segmentCells count]; i++) {
        NIPSortSegmentCell *cell =[_segmentCells objectAtIndex:i];
        cell.frame = CGRectMake(x, y, segWidth, _contentView.size.height);
        if (i>0) {
            UIView *sepView = _sepViews[i-1];
            sepView.frame = CGRectMake(x-self.segmentSepWith, y, self.segmentSepWith, _contentView.size.height);
        }
        x += segWidth+self.segmentSepWith;
    }  
}
@end
