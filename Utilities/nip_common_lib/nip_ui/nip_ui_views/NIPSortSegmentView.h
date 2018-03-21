//
//  NIPSortSegmentView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"
#import "NIPControl.h"

@class NIPSortSegmentView;

/**
 *  NIPSortSegmentView是UISegmentView的自定义版本
 */
@interface NIPSortSegmentCell : NIPView
@property(nonatomic) BOOL descending;
@property(nonatomic) NSUInteger segmentIndex;
@property(nonatomic) BOOL selected;
@property(nonatomic,copy) NSString *title;
- (void)renderCell;
@end

/**
 *  NIPSortSegmentView是支持多个字段排序控件
 */
@interface NIPSortSegmentView : NIPControl  {
    NSMutableArray *_segmentCells;
}
@property(nonatomic) NSUInteger selectedIndex;
@property(nonatomic) Class cellClass;
@property(nonatomic,strong) NSArray *segmentTitles;
@property(nonatomic,strong) UIColor *segmentSepColor;
@property(nonatomic) CGFloat segmentSepWith;
@property(nonatomic) UIEdgeInsets edgeInsets;
@property(nonatomic,readonly) UIView *contentView;

-(id)initWithFrame:(CGRect)frame;
-(BOOL)isSegmentDecending:(NSUInteger)index;

@end
