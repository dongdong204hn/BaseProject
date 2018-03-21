//
//  NIPSegmentView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"
#import "NIPControl.h"

/**
 *  NIPSegmentView使用的cell
 */
@interface ZBSegmentCell : NIPView
@property(nonatomic,readonly) NSInteger segmentIndex;
@property(nonatomic) BOOL selected;
@property(nonatomic,readonly) UILabel *titleLabel;
@property(nonatomic,copy) NSString *title;
- (void)renderCell;
@end

/**
 *  NIPSegmentView是UISegmentView的自定义版本
 */
@interface NIPSegmentView : NIPControl

@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,readonly) NSInteger segmentCount;
@property(nonatomic) UIEdgeInsets edgeInsets;
@property(nonatomic) Class segmentItemClass;

- (void)setTitles:(NSArray*)titles;
- (void)addSegmentTitle:(id)title;
@end
