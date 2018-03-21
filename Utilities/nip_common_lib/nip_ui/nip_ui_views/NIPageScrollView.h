//
//  NIPageScrollView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

@interface NIPageCell : UIView
@property(nonatomic,strong) UIView *contentView;
@property(nonatomic) NSInteger pageIndex;
@property(nonatomic) BOOL faded;
@end

@class NIPageScrollView;

typedef NS_ENUM(NSInteger, ZBPageScrollViewStyle) {
    ZBPageScrollViewStyleLinear,
    ZBPageScrollViewStyleLinearConainter,
    ZBPageScrollViewStyleLinearPaged,
    ZBPageScrollViewStyleCoverFlow
};

/**
 *  一个支持图片滚动的类，可以自动回收不可见的cell，实现得不好，正在寻找替代方案
 */
@protocol ZBPageScrollViewDelegate <NSObject>
- (NSInteger)numberOfPagesOfPageScrollView:(NIPageScrollView *)scrollView;
- (UIView*)pageSrollView:(NIPageScrollView*)scrollView
      viewForPageAtIndex:(NSInteger)index
                 reusing:(UIView*)reusableView;

@optional
- (void)pageScrollViewBeginScroll:(NIPageScrollView *)scrollView;
- (void)pageScrollViewDidScroll:(NIPageScrollView *)scrollView;
- (void)pageScrollViewEndScroll:(NIPageScrollView *)scrollView;
- (void)pageScrollView:(NIPageScrollView *)scrollView centerPageChanged:(NSInteger)index previousPage:(NSInteger)previousInteger;
- (void)pageScrollView:(NIPageScrollView *)scrollView bounced:(NIPDirection)direction;
- (void)pageScrollView:(NIPageScrollView *)scrollView pageSelectedAtIndex:(NSInteger)pageIndex;
@end

@interface NIPageScrollView : UIScrollView<UIScrollViewDelegate>

// Set the DataSource for the Scroll Suite
@property (nonatomic, weak) id<ZBPageScrollViewDelegate> pageViewdelegate;
@property (nonatomic) ZBPageScrollViewStyle style;
@property (nonatomic) CGFloat pageSpace;
@property (nonatomic) CGSize  pageSize;
@property (nonatomic) BOOL scrollPageBoundary;
@property (nonatomic) BOOL fadeNoneCenterItem;
@property (nonatomic) BOOL enbalePageSelection;
@property (nonatomic) BOOL notifyPageChangeWhenScrolling;
@property (nonatomic) NSInteger placeHolder;
@property (nonatomic) CGFloat centerOffsetX;


@property (nonatomic,readonly) NSInteger centerPageIndex;

- (id)initWithFrame:(CGRect)aFrame;
- (void)reloadData;
- (void)clearPages;
- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated;
- (UIView*)pageAtIndex:(NSInteger)index;
- (NSArray*)visiblePages;

@end
