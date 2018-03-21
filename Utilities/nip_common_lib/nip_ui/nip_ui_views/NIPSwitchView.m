//
//  NIPSwitchView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSwitchView.h"
#import "UIView+NIPBasicAdditions.h"


@implementation NIPSwitchView {
    UIImageView *_backgroundView;
    UIImageView *_thumbView;
    UIPanGestureRecognizer *_panGesture;
}

@dynamic backgroundImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    }
    return self;
}

- (void)setEnableSwitch:(BOOL)enableSwitch {
    if (enableSwitch&&!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        [self addGestureRecognizer:_panGesture];
    } else {
        if (_panGesture) {
            [self removeGestureRecognizer:_panGesture];
            _panGesture = nil;
        }
    }
}

- (CGRect)frameForItem:(NSInteger)index {
    if (self.itemArray.count>0) {
        CGFloat width = (self.bounds.size.width-_edgeInsets.left-_edgeInsets.right)/self.itemArray.count;
        CGFloat x = _edgeInsets.left+width*index;
        UIView *item = [self.itemArray objectAtIndex:0];
        x += (width-item.frame.size.width)/2;
        CGFloat y = _edgeInsets.top +(self.bounds.size.height -_edgeInsets.top -_edgeInsets.bottom -item.frame.size.height)/2;
        return CGRectMake(x, y, item.width, item.height);
    }
    return CGRectZero;
}

- (CGRect)frameForItemHighlight:(NSInteger)index {
    CGFloat width = (self.bounds.size.width-_edgeInsets.left-_edgeInsets.right)/self.itemArray.count;
    CGFloat x = width*index;
    _thumbView.width = width+_edgeInsets.left+_edgeInsets.right;
    CGFloat y = (self.height-self.thumbImage.size.height)/2;
    return CGRectMake(x-self.thumbImageShadow.left,
                      y-self.thumbImageShadow.top,
                      _thumbView.width+self.thumbImageShadow.left+self.thumbImageShadow.right,
                      self.thumbImage.size.height+self.thumbImageShadow.top+self.thumbImageShadow.bottom);
}

- (CGRect)tapAreaForItem:(NSInteger)index {
    CGFloat width = (self.bounds.size.width-_edgeInsets.left-_edgeInsets.right)/self.itemArray.count;
    CGFloat x = width*index;
    return CGRectMake(x+_edgeInsets.left,
                      _edgeInsets.top,
                      width,
                      self.bounds.size.height-_edgeInsets.top-_edgeInsets.bottom);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (!_backgroundView) {
        _backgroundView =  [[UIImageView alloc] initWithImage:backgroundImage];;
        [self insertSubview:_backgroundView atIndex:0];
    } else {
        _backgroundView.image = backgroundImage;
    }
    [self setNeedsLayout];
}

- (void)setThumbImage:(UIImage *)highlightBackgroundImage {
    _thumbImage = highlightBackgroundImage;
    _thumbView = [[UIImageView alloc] initWithImage:highlightBackgroundImage];
    if (_backgroundView) {
        [self insertSubview:_thumbView atIndex:1];
    } else {
        [self insertSubview:_thumbView atIndex:0];
    }
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.selectedIndex==selectedIndex
        ||selectedIndex<0
        ||selectedIndex>=self.itemArray.count) {
        return;
    }
    [self renderItem:self.selectedIndex highlight:NO];
    _selectedIndex = selectedIndex;
    [self renderItem:self.selectedIndex highlight:YES];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (_thumbView) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             _thumbView.frame = [self frameForItemHighlight:self.selectedIndex];
                         }
                         completion:nil];
    }
    
}


- (void)renderItem:(NSInteger)index highlight:(BOOL)highlight {
    UIView *view = [self.itemArray objectAtIndex:index];
    if ([view isKindOfClass:[UIImageView class]]) {
        ((UIImageView*)view).highlighted = highlight;
    } else if ([view isKindOfClass:[UILabel class]]) {
        ((UILabel*)view).textColor = highlight?self.highlightTextColor:self.textColor;
        ((UILabel*)view).shadowColor = highlight?self.highlightTextShadowColor:nil;
        ((UILabel*)view).font = highlight?self.highlightTextFont:self.textFont;
    }
}

- (void)setItemArray:(NSArray *)itemArray {
    _itemArray = itemArray;
    for (UIView *view in itemArray) {
        [self addSubview:view];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    _backgroundView.frame = self.bounds;
    _thumbView.frame = [self frameForItemHighlight:self.selectedIndex];
    [self renderItem:self.selectedIndex highlight:YES];
    NSInteger index = 0;
    for (UIView *view in self.itemArray) {
        view.frame = [self frameForItem:index];
        if  (index!=self.selectedIndex) {
            [self renderItem:index highlight:NO];
        }
        index++;
    }
}

- (void)tapped:(UITapGestureRecognizer*)sender {
    if (sender.state==UIGestureRecognizerStateRecognized) {
        CGPoint pos = [sender locationInView:self]; 
        for (NSInteger index=0;index<self.itemArray.count;index++) {
            if (CGRectContainsPoint([self tapAreaForItem:index], pos) ) {
                self.selectedIndex = index;
                break;
            }
        }
    }
}

- (void)panned:(UIPanGestureRecognizer*)pan {
    static CGFloat initPos;
    if (pan.state==UIGestureRecognizerStateBegan) {
        initPos = _thumbView.left;
    } else if (pan.state==UIGestureRecognizerStateChanged) {
        CGPoint point = [pan translationInView:self];
        if (point.x<0&&self.selectedIndex==0) {
            return;
        } if (point.x>0&&self.selectedIndex==self.itemArray.count-1) {
            return;
        }
        CGRect preRect = [self frameForItem:self.selectedIndex-1];
        CGRect nextRect = [self frameForItem:self.selectedIndex+1];
        if (self.selectedIndex<self.itemArray.count-1) {
            _thumbView.left = MIN(initPos+point.x,nextRect.origin.x);
        } else if (self.selectedIndex>0) {
            _thumbView.left = MAX(initPos+point.x,preRect.origin.x);
        }
    } else if (pan.state==UIGestureRecognizerStateEnded) {
        CGFloat velocitx = [pan velocityInView:self].x;
        CGRect preRect = [self frameForItem:self.selectedIndex-1];
        CGRect nextRect = [self frameForItem:self.selectedIndex+1];
        if (velocitx<-200.0f||_thumbView.left<CGRectGetMidX(preRect)) {
            self.selectedIndex--;
        } else if (velocitx>200.0f||_thumbView.right>CGRectGetMidX(nextRect)){
            self.selectedIndex++;
        } else {
            _thumbView.frame = [self frameForItemHighlight:self.selectedIndex];   
        }        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
