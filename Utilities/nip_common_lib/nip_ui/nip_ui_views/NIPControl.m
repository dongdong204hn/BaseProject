//
//  NIPControl.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPControl.h"

@implementation NIPControl

@dynamic backgroundImage;
@synthesize backgroundView;
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
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:_backgroundView atIndex:0];
    }
    _backgroundView.image = backgroundImage;
}

- (UIImage*)backgroundImage {
    return _backgroundView.image;
}



- (void)layoutSubviews {
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
