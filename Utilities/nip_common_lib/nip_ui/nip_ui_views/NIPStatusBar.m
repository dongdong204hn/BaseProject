//
//  NIPStatusBar.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPStatusBar.h"

@implementation NIPStatusBar

@synthesize contentView=_contentView;

+ (NIPStatusBar*)bar {
    NIPStatusBar *bar = [[NIPStatusBar alloc] initWithFrame:CGRectZero];
    return bar;
}

- (id)initWithFrame:(CGRect)frame
{
    CGRect s=[[UIApplication sharedApplication] statusBarFrame];
    self = [super initWithFrame:s];
    if (self != nil) {
        self.windowLevel=UIWindowLevelStatusBar+1.0f;
        self.backgroundColor=[UIColor blackColor];
        self.hidden = NO;
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:_contentView];
}

- (void)destroy {
    [self removeFromSuperview];
}

@end
