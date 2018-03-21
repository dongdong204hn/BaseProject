//
//  NIPopupMaskView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPopupMaskView.h"

@implementation NIPopupMaskView {
    UIView *_maskView;
    UITapGestureRecognizer *_maskTapGesture;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_maskView];
        
        self.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        self.wouldCloseByBackgroundtap = YES;
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    [super setContentView:contentView];
    
    _maskView.backgroundColor = self.maskColor;
    if (contentView) {
        [self addSubview:contentView];
    }
}

- (void)setWouldCloseByBackgroundtap:(BOOL)wouldCloseByBackgroundtap {
    if (wouldCloseByBackgroundtap) {
        if (!_maskTapGesture) {
            _maskTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
            [_maskView addGestureRecognizer:_maskTapGesture];
        }
    } else {
        if (_maskTapGesture) {
            [_maskView removeGestureRecognizer:_maskTapGesture];
            _maskTapGesture = nil;
        }
    }
}

- (BOOL)wouldCloseByBackgroundtap {
    return (_maskTapGesture!=nil);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.frame = newSuperview.bounds;
}

- (void)doShowAnimationOnComplete:(void (^)(void))complete {
    __block BOOL superAnimationComplete = NO;
    __block BOOL maskAnimationComplete = NO;
    
    superAnimationComplete = NO;
    maskAnimationComplete = NO;
    
    void (^checkAnimationComplete)(void) = ^ {
        if (superAnimationComplete
            &&maskAnimationComplete) {
            complete();
        }
    };
    
    [super doShowAnimationOnComplete:^{
        superAnimationComplete = YES;
        checkAnimationComplete();
    }];
    
    if (self.animationType==ZBPopupAnmiationFade) {
        _maskView.alpha = 0.0;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             _maskView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             maskAnimationComplete = YES;
                             checkAnimationComplete();
                         }];
    } else {
        maskAnimationComplete = YES;
        checkAnimationComplete();
    }
}

- (void)doCloseAnimationOnComplete:(void (^)(void))complete {
    __block BOOL superAnimationComplete = NO;
    __block BOOL maskAnimationComplete = NO;
    
    superAnimationComplete = NO;
    maskAnimationComplete = NO;
    
    void (^checkAnimationComplete)(void) = ^ {
        if (superAnimationComplete
            &&maskAnimationComplete) {
            complete();
        }
    };
    
    [super doCloseAnimationOnComplete:^{
        superAnimationComplete = YES;
        checkAnimationComplete();
    }];
    
    if (self.animationType==ZBPopupAnmiationFade) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             _maskView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             maskAnimationComplete = YES;
                             checkAnimationComplete();
                         }];
    } else {
        maskAnimationComplete = YES;
        checkAnimationComplete();
    }
}

- (void)maskViewTapped:(UITapGestureRecognizer*)tap {
    if (!self.contentView.userInteractionEnabled
        ||!CGRectContainsPoint(self.contentView.bounds, [tap locationInView:self.contentView])) {
        [self close];
    }
}


@end
