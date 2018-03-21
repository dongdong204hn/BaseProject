//
//  NIPLayoutBase.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPLayoutBase.h"
#import "NIPHorizontalLayout.h"
#import "NIPVerticalLayout.h"
#import "NIPGridLayout.h"

@implementation NIPLayoutItem

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NIPLayoutItem class]]) {
        return (self.view ==((NIPLayoutItem*)object).view);
    }
    return NO;
}

@end

@implementation NIPLayoutBase


@dynamic leftPad;
@dynamic rightPad;
@dynamic topPad;
@dynamic bottomPad;

+ (NIPLayoutBase*)layoutOfType:(ZBLayoutType)type {
    NIPLayoutBase *layout = nil;
    if (type==ZBLayoutTypeHorizon) {
        layout = [[NIPHorizontalLayout alloc] initWithFrame:CGRectZero];
    } else if (type==ZBLayoutTypeVertical) {
        layout = [[NIPVerticalLayout alloc] initWithFrame:CGRectZero];
    } else if (type==ZBLayoutTypeGrid) {
        layout = [[NIPGridLayout alloc] initWithFrame:CGRectZero];
    }
    return layout;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.maximumSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        self.minimumSize = CGSizeMake(0, 0);
    }
    return self;
}

- (void)setLeftPad:(CGFloat)leftPad {
    _contentInsets.left = leftPad;
}
- (void)setRightPad:(CGFloat)rightPad {
    _contentInsets.right = rightPad;
}
- (void)setTopPad:(CGFloat)topPad {
    _contentInsets.top = topPad;
}
- (void)setBottomPad:(CGFloat)bottomPad {
    _contentInsets.bottom = bottomPad;
}
- (CGFloat)leftPad {
    return _contentInsets.left;
}
- (CGFloat)rightPad {
    return _contentInsets.right;
}
- (CGFloat)topPad {
    return _contentInsets.top;
}
- (CGFloat)bottomPad {
    return _contentInsets.bottom;
}

- (NSInteger)layoutableSubviewCount {
    return _layoutItems.count;
}

- (void)addSubview:(UIView*)subview {
    [self insertSubview:subview atIndex:_layoutItems.count];
}

- (void)addSubview:(UIView*)subview withSpace:(CGFloat)space option:(ZBLayoutOptionMask)option {
    [self insertSubview:subview withSpace:space option:option atIndex:_layoutItems.count];
}

- (void)addSubview:(UIView*)subview withSpace:(CGFloat)space {
    [self insertSubview:subview withSpace:space option:self.defaultSubViewLayoutOption atIndex:_layoutItems.count];
}

- (void)addSubview:(UIView*)subview withOpion:(ZBLayoutOptionMask)option {
    [self insertSubview:subview withSpace:self.defaultSpacing option:option atIndex:_layoutItems.count];
}

- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index {
    [self insertSubview:subview withSpace:self.defaultSpacing option:self.defaultSubViewLayoutOption atIndex:index];
}

- (void)insertSubview:(UIView*)subview withSpace:(CGFloat)space option:(ZBLayoutOptionMask)aligment atIndex:(NSInteger)index {
    if (subview==_backgroundView
        ||aligment&ZBLayoutOptionDontLayout) {
        [super addSubview:subview];
        return;
    }
    if (_layoutItems==nil) {
        _layoutItems = [NSMutableArray arrayWithCapacity:4];
    }
    
    NIPLayoutItem *newItem = [[NIPLayoutItem alloc] init];
    newItem.spacing = space;
    newItem.layoutOptionMask = aligment;
    newItem.view = subview;
    
    if ([_layoutItems indexOfObject:newItem]==NSNotFound) {
        [super addSubview:subview];
        [_layoutItems insertObject:newItem atIndex:index];
    }
}

- (NSUInteger)indexOfLayoutItemToSubView:(UIView*)subView {
    NSUInteger index = 0;
    for (NIPLayoutItem *item in _layoutItems) {
        if (item.view==subView) {
            return index;
        }
        index++;
    }
    return NSNotFound;
}

- (void)moveSubview:(UIView*)subView toIndex:(NSInteger)toIndex {
    NSInteger index = [self indexOfLayoutItemToSubView:subView];
    if (index!=NSNotFound) {
        NIPLayoutItem *item = [_layoutItems objectAtIndex:index];
        [_layoutItems removeObjectAtIndex:index];
        [_layoutItems insertObject:item atIndex:toIndex];
    }
}

- (void)removeSubView:(UIView*)subView {
    NSInteger index = [self indexOfLayoutItemToSubView:subView];
    if (index!=NSNotFound) {
        [_layoutItems removeObjectAtIndex:index];
        [subView removeFromSuperview];
        [self setNeedsLayout];
    }    
}

- (void)removeAllSubViews {
    for (NIPLayoutItem *item in _layoutItems) {
        [item.view removeFromSuperview];
    }
    [_layoutItems removeAllObjects];
}

- (NSUInteger)indexOfSubView:(UIView*)subView {
    NSUInteger index = 0;
    for (NIPLayoutItem *item in _layoutItems) {
        if (item.view==subView) {
            return index;
        }
        index ++;
    }
    return NSNotFound;
}

- (void)resizeToContent {   
    for (NIPLayoutItem *item in _layoutItems) {
        if ([item.view conformsToProtocol:@protocol(NIPLayoutable)]) {
            [(id<NIPLayoutable>)item.view resizeToContent];
        }
    }
    CGRect frame = self.frame;
    frame.size = [self neededSizeForContent];
    self.frame = frame;
}


- (CGSize)neededSizeForContent {
    CGSize size= [self computeContentSizeForContent];
    size.width = MAX(self.minimumSize.width, size.width);
    size.width = MIN(self.maximumSize.width, size.width);
    size.height = MAX(self.minimumSize.height, size.height);
    size.height = MIN(self.maximumSize.height, size.height);
    return size;
}

- (CGSize)computeContentSizeForContent {
    return self.frame.size;
}

@end
