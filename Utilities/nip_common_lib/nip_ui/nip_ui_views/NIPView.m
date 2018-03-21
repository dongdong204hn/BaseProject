//
//  NIPView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

@implementation NIPView

@dynamic backgroundImage;
@synthesize backgroundView=_backgroundView;
@synthesize backgroundShadow;
@synthesize dontAutoResizeInLayout;
@synthesize contentEdgeInsets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (![_backgroundView isKindOfClass:[UIImageView class]]) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
    }
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        [super insertSubview:_backgroundView atIndex:0];
    }
    [(UIImageView*)_backgroundView setImage:backgroundImage];
}

- (UIImage*)backgroundImage {
    if ([_backgroundView isKindOfClass:[UIImageView class]]) {
      return [(UIImageView*)_backgroundView image];
    }
    return nil;
}

- (void)setBackgroundView:(UIView *)backgroundView  {
    if (backgroundView) {
        [super insertSubview:backgroundView atIndex:0];
    } else {
        [_backgroundView removeFromSuperview];
    }
    _backgroundView = backgroundView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    if (_backgroundView) {
        UIEdgeInsets edge = self.backgroundShadow;
        _backgroundView.frame = CGRectMake(frame.origin.x-edge.left,
                                           frame.origin.y-edge.top,
                                           frame.size.width+(edge.left+edge.right),
                                           frame.size.height+(edge.top+edge.bottom));
        [self sendSubviewToBack:_backgroundView];
    }
}

-(void)resizeToContent {
    
}

@end
