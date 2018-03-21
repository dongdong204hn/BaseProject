//
//  NIPopupBase.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPopupBase.h"
#import "nip_basic_utils.h"

@implementation NIPopupBase {
    UIView *_contentView;
    NIPTimer *_timer;
}

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.animationType = ZBPopupAnmiationFade;
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
}

- (void)setContentView:(UIView*)contentView {
    [_contentView removeFromSuperview];
    _contentView = contentView;
}

- (UIView*)contentView {
    return _contentView;
}

- (void)showInController:(UIViewController *)controller {
    [self showInView:controller.view];
}

- (void)showInView:(UIView*)view {
    if (view) {
        [view addSubview:self];
        [self doShowAnimationOnComplete:^{
            //do nothing now
        }];
    }
}

- (void)closeAfterTimeInterval:(NSTimeInterval)interval {
    __weak typeof(self) weakSelf = self;
    [_timer invalidate];
    _timer = [NIPTimer timerWithInterval:interval repeats:NO
                                 onFire:^{
                                     [weakSelf close];
                                 }];
}

- (void)close {
    if (_timer) {
        [_timer invalidate];
    }
    
    if (self.onCloseBlock) {
        self.onCloseBlock();
    }
    [self doCloseAnimationOnComplete:^{
        [self removeFromSuperview];
    }];
}

- (void)doShowAnimationOnComplete:(void (^)(void))complete {
    if (self.animationType==ZBPopupAnmiationFade) {
        self.contentView.alpha = 0.0;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             self.contentView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                            complete();
                         }];
    } else {
        complete();
    }
}

- (void)doCloseAnimationOnComplete:(void (^)(void))complete {
    if (self.animationType==ZBPopupAnmiationFade) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.contentView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             complete();
                         }];
    } else {
        complete();
    }
}

@end
