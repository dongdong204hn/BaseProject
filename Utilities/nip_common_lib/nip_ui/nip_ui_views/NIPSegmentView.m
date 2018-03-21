//
//  NIPSegmentView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSegmentView.h"
#import "NIPIconTextView.h"

@interface ZBSegmentCell()
@property(nonatomic,readwrite) NSInteger segmentIndex;
@end

@implementation ZBSegmentCell {
    UILabel *_titleLabel;
}

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.autoresizingMask =UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

- (void)renderCell {
    
}

@end

@implementation NIPSegmentView {
    NSArray *_titles;
    NSMutableArray *_segmentArray;
    UIImage *_sepImage;
}
@synthesize selectedIndex=_selectedIndex;

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.segmentItemClass =  [ZBSegmentCell class];
        _segmentArray = [NSMutableArray array];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segmentTapped:)]];
        _selectedIndex = -1;
    }
    return self;
}

- (void)setTitles:(NSArray*)titles {
    _titles = titles;
    [self resetAllSegments];
}

- (NSInteger)segmentCount {
    return _segmentArray.count;
}

- (void)setSegmentTitles:(NSArray*)titles {
    _titles = titles;
    [self resetAllSegments];
}

- (void)resetAllSegments {
    _selectedIndex = -1;
    for (UIView *segment in _segmentArray) {
        [segment removeFromSuperview];
    }
    [_segmentArray removeAllObjects];
    
    for (NSString *title in _titles) {
        [self addSegmentTitle:title];
    }
    [self setSelectedIndex:0];
}

- (void)addSegmentTitle:(id)title {
    ZBSegmentCell *cell = [(ZBSegmentCell*)[self.segmentItemClass alloc] initWithFrame:CGRectZero];
    cell.title = title;
    cell.segmentIndex = _segmentArray.count;
    [cell renderCell];
    [_segmentArray addObject:cell];
    [self addSubview:cell];
    
    if (_selectedIndex == -1) {
        self.selectedIndex = 0;
    }
}

- (UIView*)segmentAtIndex:(NSInteger)index {
    return _segmentArray[index];
}


- (void)setSepImage:(UIImage*)sepImage {
    _sepImage = sepImage;
    [self setNeedsDisplay];
}

-(void)setSelectedIndex:(NSInteger)highlightIndex {
    if (_selectedIndex!=highlightIndex&&highlightIndex<_segmentArray.count) {
        BOOL shouldSendActions = NO;
        if (_selectedIndex>=0) {
            shouldSendActions = YES;
            
            ZBSegmentCell *cell = [_segmentArray objectAtIndex:_selectedIndex];
            cell.selected = NO;
            [cell renderCell];
        }
        
        _selectedIndex = highlightIndex;
        
        ZBSegmentCell *cell = [_segmentArray objectAtIndex:_selectedIndex];
        cell.selected = YES;
        [cell renderCell];
        
        if (shouldSendActions) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}


-(void)segmentTapped:(UITapGestureRecognizer*)sender {
    if (sender.state!=UIGestureRecognizerStateRecognized) {
        return;
    }
    NSUInteger index = 0;
    for (UIView *segmentView in _segmentArray) {
        if (CGRectContainsPoint(segmentView.bounds, [sender locationInView:segmentView])) {
            self.selectedIndex = index;
        }
        index ++;
    }
}


-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;
    if ([_segmentArray count]==0) {
        return;
    }
    _backgroundView.frame = rect;
    
    
    rect = CGRectMake(rect.origin.x+self.edgeInsets.left,
                      rect.origin.y+self.edgeInsets.top,
                      rect.size.width-self.edgeInsets.left-self.edgeInsets.right,
                      rect.size.height-self.edgeInsets.top-self.edgeInsets.bottom);
    CGFloat sepWidth = _sepImage.size.width;
    rect.size.width -= sepWidth*(_segmentArray.count-1);
    
    CGFloat segWidth = rect.size.width/[_segmentArray count];
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    for (int i=0; i<[_segmentArray count]; i++) {
        ZBSegmentCell *segment =[_segmentArray objectAtIndex:i];
        segment.frame = CGRectMake(x, y, segWidth, rect.size.height);
        x += segWidth+sepWidth;
    }
}

@end
