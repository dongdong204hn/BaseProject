//
//  NIPTableContainerView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPTableContainerView.h"

@implementation NIPTableContainerView {
    UITableView *_tableView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _tableView.dataSource = (id<UITableViewDataSource>)self;
        _tableView.delegate = (id<UITableViewDelegate>)self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        self.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setHeaderView:(UIView *)headerView {
    _tableView.tableHeaderView = headerView;
}

- (void)reload {
    [_tableView reloadData];
}

- (void)scrollCellVisible:(UIView*)cellView {
    NSUInteger index = [self.cellViews indexOfObject:cellView];
    if (index!=NSNotFound) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)reloadCellView:(UIView*)cellView  animated:(BOOL)animated {
    if (self.cellViews.count==0) {
        return;
    }
    NSUInteger index = [self.cellViews indexOfObject:cellView];
    if (index!=NSNotFound) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:animated?UITableViewRowAnimationAutomatic:UITableViewRowAnimationNone];
    }
}

#pragma mark -
#pragma mark tableView delegate&dataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.sectionView.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return self.sectionView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellViews.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *viewForCell = self.cellViews[indexPath.row];
    if (viewForCell.hidden) {
        return 0;
    } else  {
        return viewForCell.frame.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = self.cellSelectionStyle;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:self.cellViews[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellSelectBlock) {
        self.cellSelectBlock(indexPath);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView != scrollView) {
        return;
    }
    
    if (self.didScrollBlock) {
        self.didScrollBlock(scrollView.contentOffset);
    }
}

@end
