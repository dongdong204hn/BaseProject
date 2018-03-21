//
//  NIPopupToastView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NIPopupToastView.h"
#import "NIPTimer.h"

@implementation NIPopupToastView {
    UILabel *_textLabel;
    NIPTimer *_timer;
}

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
		self.layer.cornerRadius = 3;
		
		_textLabel = [[UILabel alloc] initWithFrame:self.bounds];
		_textLabel.textAlignment = NSTextAlignmentCenter;
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		_textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 0;
		[self addSubview:_textLabel];
    }
    return self;
}


+ (void)showToast:(NSString*)text inController:(UIViewController*)controller {
    NIPopupToastView *toastView = [[NIPopupToastView alloc] initWithFrame:CGRectZero];
    [toastView setTextAndResizeToastView:text];
    [toastView showInController:controller];
}

- (void)setTextAndResizeToastView:(NSString*)text {
    _textLabel.text = text;
    
    CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(220, CGFLOAT_MAX)];
    self.frame = CGRectMake((320-textSize.width-15)/2, 150, textSize.width+15, textSize.height+15);
    _textLabel.frame = CGRectMake(7.5, 7.5, textSize.width, textSize.height);
}

- (void)showInController:(UIViewController *)controller {
    if (controller) {
        [controller.view addSubview:self];
    } else {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [self makeCenter];
    self.alpha = 0.0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [_timer invalidate];
    _timer = [NIPTimer timerWithInterval:2.0 repeats:NO
                                 onFire:^{
                                     [weakSelf close];
                                 }];
}

- (void)close {
    if (_timer) {
        [_timer invalidate];
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
