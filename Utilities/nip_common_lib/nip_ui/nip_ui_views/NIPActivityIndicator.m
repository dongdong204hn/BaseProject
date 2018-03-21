//
//  NIPActivityIndicator.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NIPActivityIndicator.h"

@implementation NIPActivityIndicator {
    UIImageView * _indicatorView;
}

@dynamic indicatorImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _indicatorView = [[UIImageView alloc] initWithFrame:self.bounds];
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    _indicatorView.image = indicatorImage;
}

- (UIImage*)indicatorImage {
    return _indicatorView.image;
}

- (void)setIndicatorImages:(NSArray *)indicatorImages {
    _indicatorView.animationDuration = 1.0;
    _indicatorView.animationImages = indicatorImages;
}

- (NSArray*)indicatorImages {
    return _indicatorView.animationImages;
}

- (void)startAnimating {
    if (_indicatorView.animationImages) {
        [_indicatorView startAnimating];
    } else {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = [NSNumber numberWithFloat:M_PI*2];
        animation.duration = 1.0;
        animation.cumulative = YES;
        animation.repeatCount = NSIntegerMax;
        [self.layer addAnimation:animation forKey:@"rotate"];
        self.hidden = NO;
    }
}

- (void)stopAnimating {
    if (_indicatorView.animationImages) {
        [_indicatorView stopAnimating];
    } else {
        [self.layer removeAnimationForKey:@"rotate"];
        self.hidden = YES;
    }
}

- (BOOL)isAnimating {
    if (_indicatorView.animationImages) {
        return [_indicatorView isAnimating];
    } else {
        return [self.layer animationForKey:@"rotate"]!=nil;
    }
}

@end
