//
//  NIPTableContainerView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

typedef void (^CellSelectBlock)(NSIndexPath* indexPath);
typedef void (^DidScrollBlock)(CGPoint contentOffset);

/**
 *  NIPTableContainerView使用UITableView来布局管理子view
 */
@interface NIPTableContainerView : NIPView
@property(nonatomic,readonly) UITableView *tableView;
@property(nonatomic,strong) NSArray *cellViews;
@property(nonatomic,strong) UIView *headerView;
@property(nonatomic,strong) UIView *sectionView;

@property(nonatomic) UITableViewCellSelectionStyle cellSelectionStyle;
@property(nonatomic,copy) CellSelectBlock cellSelectBlock;
@property(nonatomic,copy) DidScrollBlock didScrollBlock;

- (void)reloadCellView:(UIView*)cellView animated:(BOOL)animated;
- (void)reload;
- (void)scrollCellVisible:(UIView*)cellView;
@end
