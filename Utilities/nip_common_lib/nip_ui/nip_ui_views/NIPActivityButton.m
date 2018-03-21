//
//  NIPActivityButton.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPActivityButton.h"

@implementation NIPActivityButton {
    UIButton *_button;
    UIActivityIndicatorView *_indicatorView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = self.bounds;
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_button setTitle:title forState:UIControlStateNormal];
}

- (void)buttonPressed:(id)sender {
    if (!self.inActivity) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setInActivity:(BOOL)inActivity {
    _inActivity = inActivity;
    if (inActivity) {
        if (!_indicatorView) {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [self addSubview:_indicatorView];
        }
        [_button setTitle:self.titleInActivity forState:UIControlStateNormal];
        [_indicatorView startAnimating];
    } else {
        [_button setTitle:self.title forState:UIControlStateNormal];
        [_indicatorView stopAnimating];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_inActivity) {
        CGSize buttonTitleSize = [[_button titleForState:UIControlStateNormal] sizeWithAttributes:@{ NSFontAttributeName : _button.titleLabel.font}];
        if (buttonTitleSize.width>5) {
            [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, buttonTitleSize.width, 0, 0)];
            _indicatorView.center = CGPointMake(_indicatorView.width/2, self.height/2);
        } else {
            [_button setTitleEdgeInsets:UIEdgeInsetsZero];
            _indicatorView.center = CGRectCenterPoint2(self.bounds);
        }

    } else {
        [_button setTitleEdgeInsets:UIEdgeInsetsZero];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    _button.enabled = enabled;
}


@end
