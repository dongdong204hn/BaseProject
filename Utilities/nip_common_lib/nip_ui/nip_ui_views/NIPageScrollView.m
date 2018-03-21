//
//  NIPageScrollView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NIPageScrollView.h"

@implementation NIPageCell {
    UIView *_fadeMaskView;
}
- (void)setContentView:(UIView *)contentView {
    if (_contentView.superview==self) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    _contentView.center = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));
    [self insertSubview:_contentView atIndex:0];
}

- (void)setFaded:(BOOL)faded {
    if (faded) {
        if (!_fadeMaskView) {
            _fadeMaskView = [[UIView alloc] initWithFrame:self.bounds];
            _fadeMaskView.backgroundColor = [UIColor darkGrayColor];
            _fadeMaskView.alpha = 0.5;
            [self addSubview:_fadeMaskView];
        }
        _fadeMaskView.hidden = NO;
    } else {
        _fadeMaskView.hidden = YES;
    }
}
@end

@interface NIPageScrollView()
@property(nonatomic,readwrite) NSInteger centerPageIndex;
@end

@implementation NIPageScrollView  {
    NSMutableArray *_visiblePages;
    NSRange _currentVisibleRange;
    
    NSMutableArray *_recycledPages;
    NSMutableArray *_toRecyclePages;
    
    NSInteger _scollTargetPageIndex;
    NSInteger _pageCount;

    UITapGestureRecognizer *_tapGesture;
}


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) 	{
		_visiblePages   = [[NSMutableArray alloc] init];
        _recycledPages  = [[NSMutableArray alloc] init];
        _toRecyclePages  = [[NSMutableArray alloc] init];
        
        self.showsHorizontalScrollIndicator = NO;
        self.notifyPageChangeWhenScrolling = YES;
        self.delegate = self;
        
        
        self.centerPageIndex = NSNotFound;
        
        _scollTargetPageIndex = NSNotFound;
    }
    return self;
}

- (void)setEnbalePageSelection:(BOOL)enbalePageSelection {
    _enbalePageSelection = enbalePageSelection;
    if (_enbalePageSelection&&!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapped:)];
        _tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
        [self addGestureRecognizer:_tapGesture];
    } else {
        [self removeGestureRecognizer:_tapGesture];
    }
}

- (void)setPageSize:(CGSize)pageSize {
    if (CGSizeEqualToSize(self.pageSize, pageSize)) {
        return;
    }
    _pageSize = pageSize;
    [self clearPages];
}

- (void)setStyle:(ZBPageScrollViewStyle)style {
    _style = style;
    switch (style) {
        case ZBPageScrollViewStyleLinear:
            self.decelerationRate = 0;
            self.pagingEnabled = NO;
            self.scrollPageBoundary = YES;
            self.placeHolder = 2;
            break;
        case ZBPageScrollViewStyleLinearConainter:
            self.decelerationRate = 100;
            self.pagingEnabled = NO;
            self.placeHolder = 2;
            break;
            
        case ZBPageScrollViewStyleCoverFlow:
            self.pagingEnabled = YES;
            self.placeHolder = 2;
            break;
        case ZBPageScrollViewStyleLinearPaged:
            self.pagingEnabled = YES;
            self.placeHolder = 1;
            break;
        default:
            break;
    }
}

- (void)doStopScrolling {
    if (_scollTargetPageIndex!=NSNotFound
        &&_scollTargetPageIndex!=self.centerPageIndex) {
        //在ios5上，scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset 里面指定了targetContentOffset，有时不起作用。所以这里再检查一下
        [self scrollToPageAtIndex:_scollTargetPageIndex animated:YES];
        return;
    }
    
    _scollTargetPageIndex = NSNotFound;
    
    if (self.pagingEnabled) {
        [self loadCurrentVisiblePages];
    }
    
    NSRange visibleRange = [self visiblePageRangeOfScrollOffset:self.contentOffset.x];
    [self recyclePageOutofRange:visibleRange];

    if ([self.pageViewdelegate respondsToSelector:@selector(pageScrollViewEndScroll:)]) {
        [self.pageViewdelegate pageScrollViewEndScroll:self];
    }
}

- (void)doStartScrolling {
    if ([self.pageViewdelegate respondsToSelector:@selector(pageScrollViewBeginScroll:)]) {
        [self.pageViewdelegate pageScrollViewBeginScroll:self];
    }
}

#pragma mark
#pragma mark interfaces

- (void)reloadData { 
    _pageCount = [self.pageViewdelegate numberOfPagesOfPageScrollView:self];
    if (self.style==ZBPageScrollViewStyleCoverFlow||self.style==ZBPageScrollViewStyleLinearPaged) {
        self.contentSize = CGSizeMake(self.bounds.size.width*_pageCount,self.bounds.size.height);
    } else if (self.style==ZBPageScrollViewStyleLinear){
        self.contentSize = CGSizeMake((self.pageSize.width+self.pageSpace)*(_pageCount-1)+self.bounds.size.width,self.bounds.size.height);
    } else if (self.style==ZBPageScrollViewStyleLinearConainter) {
        self.contentSize = CGSizeMake(self.pageSize.width*_pageCount+self.pageSpace*(_pageCount-1),self.bounds.size.height);
    }
    if (self.centerPageIndex==NSNotFound||self.centerPageIndex>=_pageCount) {
        self.centerPageIndex = 0;
        self.contentOffset = CGPointMake(0, 0);
    }
    NSRange visibleRange = [self visiblePageRangeOfScrollOffset:self.contentOffset.x];
    [self recyclePageOutofRange:visibleRange];
    [self reloadCurrentVisiblePages];
}

- (void)clearPages {
    [self recyclePageOutofRange:NSMakeRange(-1, 0)];//这里实际上回收所有的page
    [self clearRecycledPages];
    self.contentOffset = CGPointMake(0, 0);
    self.centerPageIndex = NSNotFound;
}

- (void)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.decelerating||self.dragging) {
        return;
    }
    if (self.centerPageIndex!=index&&index>=0&&index<_pageCount) {
        [self doScrollToPageAtIndex:index animated:animated];
    }
}

- (void)doScrollToPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (!animated) {
        [self doStartScrolling];
    }
    _scollTargetPageIndex = index;
    [self setContentOffset:CGPointMake([self scrollOffsetWhenCenterAtIndex:index], 0) animated:animated];
    [self loadPagesOfRange:[self visiblePageRangeOfScrollOffset:[self scrollOffsetWhenCenterAtIndex:index]]];
    if (!animated) {
        [self doStopScrolling];
    }
}

- (UIView*)pageAtIndex:(NSInteger)index {
    for (NIPageCell *cell in _visiblePages) {
        if (cell.pageIndex==index) {
            return cell.contentView;
        }
    }
    return nil;
}

- (NSArray*)visiblePages {
    NSMutableArray *array = [NSMutableArray array];
    for (NIPageCell *cell  in _visiblePages) {
        [array addObject:cell.contentView];
    }
    return array;
}

#pragma mark -
#pragma mark load pages

- (void)setCenterPageIndex:(NSInteger)centerPageIndex {
    if (_centerPageIndex==centerPageIndex||(centerPageIndex!=NSNotFound&&(centerPageIndex<0||centerPageIndex>=_pageCount))) {
        return;
    }
    NSInteger previousPage = _centerPageIndex;
    _centerPageIndex = centerPageIndex;

    if (previousPage>=_pageCount) {
        previousPage = NSNotFound;
    }
    if (previousPage!=NSNotFound&&_centerPageIndex!=NSNotFound&&[self.pageViewdelegate respondsToSelector:@selector(pageScrollView:centerPageChanged:previousPage:)]) {
        [self.pageViewdelegate pageScrollView:self centerPageChanged:_centerPageIndex previousPage:previousPage];    
    }
}

- (void)loadCurrentVisiblePages {
    NSRange visibleRange = [self visiblePageRangeOfScrollOffset:self.contentOffset.x];
    [self loadPagesOfRange:visibleRange];
}

- (void)reloadCurrentVisiblePages {
    NSRange visibleRange = [self visiblePageRangeOfScrollOffset:self.contentOffset.x];
    [self loadPagesOfRange:visibleRange];
    for (NIPageCell *cell in _visiblePages) {
       [self.pageViewdelegate pageSrollView:self
                         viewForPageAtIndex:cell.pageIndex
                                    reusing:cell.contentView];
    }
}

- (NSRange)visiblePageRangeOfScrollOffset:(CGFloat)scrollOffset {
    if (self.style==ZBPageScrollViewStyleCoverFlow||self.style==ZBPageScrollViewStyleLinearPaged) {
        NSInteger page = [self centerIndexOfScrollOffset:scrollOffset];
        NSInteger startIndex = MAX(0,page-self.placeHolder);
        NSInteger endIndex = MIN(_pageCount-1, page+self.placeHolder);
        return NSMakeRange(startIndex, endIndex-startIndex+1);
    } else {
        CGFloat visibleStart = scrollOffset - self.bounds.size.width/2+self.pageSize.width/2-self.centerOffsetX;
        CGFloat visibleEnd = visibleStart+self.bounds.size.width;
        NSInteger startIndex = MAX(0, floor(visibleStart/(self.pageSize.width+self.pageSpace))-self.placeHolder);
        NSInteger endIndex = MIN(_pageCount-1, ceilf(visibleEnd/(self.pageSize.width+self.pageSpace))+self.placeHolder);
        return NSMakeRange(startIndex, endIndex-startIndex+1);
    }
}

- (void)loadPagesOfRange:(NSRange)range {
    if (range.length<=0) {
        return;        
    }
    if (range.location>=_currentVisibleRange.location&&range.location+range.length<=_currentVisibleRange.location+_currentVisibleRange.length) {
        return;
    }
    NSInteger pageIndex = range.location;
    NSUInteger loadedCount =0;
    NSInteger step = 1;
    while (loadedCount<range.length) {
        if (!NSLocationInRange(pageIndex,_currentVisibleRange)) {
            [self doLoadPage:pageIndex];
        }
        pageIndex += step;
        loadedCount ++;
    }
}

- (void)doLoadPage:(NSInteger)index {
    if (index<0||index>=_pageCount) {
        return;
    }

    NIPageCell *reusableCell = 0;
    if (_recycledPages.count>0) {
        reusableCell = _recycledPages.lastObject;
        [_recycledPages removeLastObject];
    }
    UIView *contentView = [self.pageViewdelegate pageSrollView:self
                                    viewForPageAtIndex:index
                                               reusing:reusableCell.contentView];
    contentView.frame = CGRectMake(0, 0, self.pageSize.width, self.pageSize.height);
    if (reusableCell==nil) {
        reusableCell = [[NIPageCell alloc] initWithFrame:CGRectZero];
    }
    reusableCell.frame = [self frameOfNewPageAtIndex:index];    
    reusableCell.contentView = contentView;
    reusableCell.pageIndex = index;
    [self transformPage:reusableCell];
    
    [self addSubview:reusableCell];
    
    [_visiblePages addObject:reusableCell];
    _currentVisibleRange = NSUnionRange(_currentVisibleRange, NSMakeRange(index, 1));
}

- (CGRect)frameOfNewPageAtIndex:(NSInteger)index {
    if (self.style==ZBPageScrollViewStyleLinear||self.style==ZBPageScrollViewStyleLinearConainter) {
        return CGRectMake((self.pageSize.width+self.pageSpace)*index+CGRectGetMidX(self.bounds)-self.pageSize.width/2-self.contentOffset.x+self.centerOffsetX, 0, self.pageSize.width, self.pageSize.height);
    } else {
        return CGRectMake(self.bounds.size.width*index, 0,self.bounds.size.width,self.bounds.size.height);
    }
}

- (void)recyclePageOutofRange:(NSRange)range {
    for (NIPageCell *cell in _visiblePages) {
        if (!NSLocationInRange(cell.pageIndex,range)) {
            [_toRecyclePages addObject:cell];
        }
    }
    for (NIPageCell *cell in _toRecyclePages) {
        [cell removeFromSuperview];
        cell.contentView.transform = CGAffineTransformIdentity; //重要,把tranform恢复为单位矩阵
        [_visiblePages removeObject:cell];
        [_recycledPages addObject:cell];
    }
    [_toRecyclePages removeAllObjects];
    _currentVisibleRange = NSIntersectionRange(range, _currentVisibleRange);
}

- (void)clearRecycledPages {
    [_recycledPages removeAllObjects];
}

- (NIPageCell*)visiblePageAtIndex:(NSInteger)index {
    for (NIPageCell *cell in _visiblePages) {
        if (cell.pageIndex==index) {
            return cell;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark tranform pages

- (void)tranformVisiblePages{
    for (NIPageCell *cell in _visiblePages) {
        [self transformPage:cell];
    }
}

- (void)transformPage:(NIPageCell*)cell {
    cell.contentView.transform = [self transformOfPageAtIndex:cell.pageIndex withScrollOffset:self.contentOffset.x];
    if (self.fadeNoneCenterItem) {
        CGFloat diff = fabs(self.contentOffset.x - [self scrollOffsetWhenCenterAtIndex:cell.pageIndex]);
        if  (fabs(diff)>(_pageSize.width+self.pageSpace)*3/5) {
            cell.faded = YES;
        } else {
            cell.faded = NO;
        }
    }
}

- (CGAffineTransform)transformOfPageAtIndex:(NSInteger)index withScrollOffset:(CGFloat)offset {
    if (self.style==ZBPageScrollViewStyleCoverFlow) {
        CGFloat diff = offset-[self scrollOffsetWhenCenterAtIndex:index];
        CGFloat scale =  1-fabs(diff)/(self.bounds.size.width)*0.12;
        CGAffineTransform transform =  CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        CGFloat translateX = (diff/self.size.width)*(self.size.width-self.pageSize.width+(1-scale)*self.pageSize.width/2-self.pageSpace);
        CGFloat translateY = -(1-scale)*_pageSize.height/2;
        return CGAffineTransformTranslate(transform, translateX, translateY);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (CGFloat)scrollOffsetWhenCenterAtIndex:(NSInteger)index {
    if (self.style==ZBPageScrollViewStyleCoverFlow||self.style==ZBPageScrollViewStyleLinearPaged) {
        return (index)*(self.bounds.size.width);
    } else {
        return index*(_pageSize.width+self.pageSpace);    
    }
}

- (NSInteger)centerIndexOfScrollOffset:(CGFloat)scrollOffset {
    if (self.style==ZBPageScrollViewStyleCoverFlow||self.style==ZBPageScrollViewStyleLinearPaged) {
        NSInteger index =  ((scrollOffset)/self.bounds.size.width*10+5)/10;
        return MAX(0, MIN(_pageCount-1, index));
    } else {
        NSInteger index =  (scrollOffset/(_pageSize.width+self.pageSpace)*10+5)/10;
        return MAX(0, MIN(_pageCount-1, index));
    }
}

#pragma mark -
#pragma mark guesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer==_tapGesture) {
        if (self.tracking&&self.decelerating) {
            return NO;
        }
    }
    return YES;
}

- (void)didTapped:(UITapGestureRecognizer*)tap {
    for (NIPageCell *cell in _visiblePages) {
        if (CGRectContainsPoint(cell.bounds, [tap locationInView:cell])) {
            if ([self.pageViewdelegate respondsToSelector:@selector(pageScrollView:pageSelectedAtIndex:)]) {
                [self.pageViewdelegate pageScrollView:self pageSelectedAtIndex:cell.pageIndex];
            }
            break;
        }
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self doStartScrolling];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger scrolledPage = [self centerIndexOfScrollOffset:scrollView.contentOffset.x];
    if (self.notifyPageChangeWhenScrolling
        ||(_scollTargetPageIndex==scrolledPage)) {
        self.centerPageIndex = scrolledPage;
    }
    [self loadCurrentVisiblePages];
    [self tranformVisiblePages];
    
    if ([self.pageViewdelegate respondsToSelector:@selector(pageScrollViewDidScroll:)]) {
        [self.pageViewdelegate pageScrollViewDidScroll:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self doStopScrolling];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self doStopScrolling];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (!self.pagingEnabled&&self.scrollPageBoundary) {
        NSInteger pageIndex = [self centerIndexOfScrollOffset:targetContentOffset->x];
        targetContentOffset->x = [self scrollOffsetWhenCenterAtIndex:pageIndex];
        _scollTargetPageIndex = pageIndex;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.pageViewdelegate respondsToSelector:@selector(pageScrollView:bounced:)]) {
        if (self.contentOffset.x>self.contentSize.width-self.bounds.size.width) {
           [self.pageViewdelegate pageScrollView:self bounced:NIPDirectionRight];
        } else if (self.contentOffset.x<0) {
           [self.pageViewdelegate pageScrollView:self bounced:NIPDirectionLeft];
        }
    }
}

@end
