//
//  NIPCustomAlertBase.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NIPCustomAlertBase.h"
#import "nip_ui_additions.h"

#define DISMISS_ANIMATION_KEY @"dismiss"
#define SHOW_ANIMATION_KEY @"show"
#define BACK_GROUND_ANIMATION_VALUE @"background"
#define CONTENT_ANIMATION_VALUE @"content"

static NSMutableArray *gPopupArray = nil; //这个全局数组用来持有NIPCustomAlertBase一个strong引用，否则会被ARC自动release


@interface NIPCustomAlertBase ()

@property (nonatomic, strong) UIWindow *restoreKeyWindow;
@property (nonatomic, assign) NSUInteger dismissButtonIndex;
@property (nonatomic, assign) BOOL duringShowAnimation;
@property (nonatomic, assign) BOOL duringDismissAnimation;

@end


@implementation NIPCustomAlertBase
@synthesize showColor = _showColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = [UIApplication sharedApplication].keyWindow.frame;
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelNormal+1.0;
        self.animationType = ZBAlertAnmiationAlert;
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    [self.contentView removeFromSuperview];
    
    _contentView = contentView;
    [self addSubview:contentView];
    [_contentView makeCenter];
}

- (void)setShowColor:(UIColor *)showColor {
    _showColor = showColor;
    if (self.isShow) {
        self.backgroundView.backgroundColor = _showColor;
    }
}

- (UIColor *)showColor {
    if (!_showColor) {
        _showColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    }
    return _showColor;
}

- (void)show {
    if (!gPopupArray) {
        gPopupArray = [NSMutableArray array];
    }
    [gPopupArray addObject:self];
    
    [self insertSubview:self.backgroundView atIndex:0];
    
    _restoreKeyWindow = [UIApplication sharedApplication].keyWindow;
    [self makeKeyAndVisible];
    
    [self willShow];
    
    self.isShow = YES;
    switch (self.animationType) {
        case ZBAlertAnmiationAlert:
            _duringShowAnimation = YES;
            [self alertShowAnimation];
            break;
        case ZBAlertAnmiationSheet:
            _duringShowAnimation = YES;
            [self sheetShowAnimation];
            break;
        default:
            [self didShow];
            break;
    }
    
}

- (void)dismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_duringDismissAnimation||_duringShowAnimation) {
        return;
    }
    
    _dismissButtonIndex = buttonIndex;
    [self willDismiss];
    self.isShow = NO;
    switch (self.animationType) {
        case ZBAlertAnmiationAlert:
            _duringDismissAnimation = YES;
            [self alertDismissAnimation];
            break;
        case ZBAlertAnmiationSheet:
            _duringDismissAnimation = YES;
            [self sheetDismissAnimation];
            break;
        default:
            [self doRemoveSelf];
            break;
    }
}

- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = self.showColor;
    }
    return _backgroundView;
}

- (void)setBackGroundView:(UIView *)maskView {
    [self.backgroundView removeFromSuperview];
    _backgroundView = maskView;
}

- (void)doRemoveSelf {
    [self didDismiss];
    
    [gPopupArray removeObject:self];
    
    self.hidden = YES;
//    [self resignKeyWindow];
    
    [_restoreKeyWindow makeKeyAndVisible];
    
    if (self.dismissBlock) {
        self.dismissBlock(_dismissButtonIndex);
    }
}

- (void)willShow {
    
}

- (void)didShow {
    
}

- (void)willDismiss {
    
}

- (void)didDismiss {
    
}


- (void)alertShowAnimation {
    if (self.contentView) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values  = @[[NSNumber numberWithFloat:0.01],
                              [NSNumber numberWithFloat:1.10],
                              [NSNumber numberWithFloat:0.90],
                              [NSNumber numberWithFloat:1.10]];
        animation.fillMode = kCAFillModeBoth;
        animation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = 0.4;
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.fillMode = kCAFillModeBoth;
        opacityAnimation.duration = 0.4;
        
        CAAnimationGroup *animationGroun = [CAAnimationGroup animation];
        animationGroun.animations = @[animation,opacityAnimation];
        [animationGroun setValue:CONTENT_ANIMATION_VALUE forKey:@"id"];
        animationGroun.delegate = self;
        [self.contentView.layer addAnimation:animationGroun forKey:SHOW_ANIMATION_KEY];
    }
    [self backgroundShowAnimation];
}

- (void)alertDismissAnimation {
    if (self.contentView) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.fillMode = kCAFillModeBoth;
        animation.fromValue = [NSNumber numberWithFloat:1.0];
        animation.toValue = [NSNumber numberWithFloat:0.0];
        animation.duration = 0.4;
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.fillMode = kCAFillModeBoth;
        opacityAnimation.duration = 0.4;
        
        CAAnimationGroup *animationGroun = [CAAnimationGroup animation];
        animationGroun.animations = @[animation,opacityAnimation];
        [animationGroun setValue:CONTENT_ANIMATION_VALUE forKey:@"id"];
        animationGroun.delegate = self;

        self.contentView.layer.opacity = 0.0;
        [self.contentView.layer addAnimation:animationGroun forKey:DISMISS_ANIMATION_KEY];
    }
    
    [self backgroundDismissAnimation];
}


- (void)sheetShowAnimation {
    if (self.contentView) {
        CGPoint endPoint =self.contentView.layer.position;
        CGPoint startPoint = CGPointMake(endPoint.x, self.height+self.contentView.height);
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:startPoint];
        animation.toValue = [NSValue valueWithCGPoint:endPoint];;
        animation.fillMode = kCAFillModeBoth;
        animation.duration = 0.2;
        animation.delegate = self;
        [animation setValue:CONTENT_ANIMATION_VALUE forKey:@"id"];
        
        self.contentView.layer.position = endPoint;
        [self.contentView.layer addAnimation:animation forKey:SHOW_ANIMATION_KEY];
    }
    
    [self backgroundShowAnimation];
}

- (void)sheetDismissAnimation {
    if (self.contentView) {
        CGPoint startPoint =self.contentView.layer.position;
        CGPoint endPoint = CGPointMake(startPoint.x, self.height+self.contentView.height);
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:startPoint];
        animation.toValue = [NSValue valueWithCGPoint:endPoint];;
        animation.fillMode = kCAFillModeBoth;
        animation.duration = 0.2;
        [animation setValue:CONTENT_ANIMATION_VALUE forKey:@"id"];
        animation.delegate = self;
        
        self.contentView.layer.position = endPoint;
        [self.contentView.layer addAnimation:animation forKey:DISMISS_ANIMATION_KEY];
    }
    [self backgroundDismissAnimation];
}

- (void)backgroundShowAnimation {
    CABasicAnimation *backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    backgroundAnimation.fromValue = (id)[NSNumber numberWithFloat:0.0];
    backgroundAnimation.toValue = (id)[NSNumber numberWithFloat:1.0];
    backgroundAnimation.fillMode = kCAFillModeBoth;
    backgroundAnimation.duration = 0.2;
    backgroundAnimation.delegate = self;
    [backgroundAnimation setValue:BACK_GROUND_ANIMATION_VALUE forKey:@"id"];
    
    self.backgroundView.layer.opacity = 1.0;
    [self.backgroundView.layer addAnimation:backgroundAnimation forKey:SHOW_ANIMATION_KEY];
}

- (void)backgroundDismissAnimation {
    CABasicAnimation *backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    backgroundAnimation.fromValue = (id)[NSNumber numberWithFloat:1.0];;
    backgroundAnimation.toValue = (id)[NSNumber numberWithFloat:0.0];
    backgroundAnimation.fillMode = kCAFillModeBoth;
    backgroundAnimation.duration = 0.2;
    backgroundAnimation.delegate = self;
    [backgroundAnimation setValue:BACK_GROUND_ANIMATION_VALUE forKey:@"id"];
    
//    self.backgroundView.layer.opacity = 0.0;
    [self.backgroundView.layer addAnimation:backgroundAnimation forKey:DISMISS_ANIMATION_KEY];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *animationId = [anim valueForKey:@"id"];
    BOOL animationComplete = NO;
    if (self.contentView) {
        animationComplete = [animationId isEqual:CONTENT_ANIMATION_VALUE];
    } else {
        animationComplete = [animationId isEqual:BACK_GROUND_ANIMATION_VALUE];
    }
    if (animationComplete) {
        if (_duringShowAnimation) {
            _duringShowAnimation = NO;
            [self didShow];
        } else if (_duringDismissAnimation) {
            _duringDismissAnimation = NO;
            [self doRemoveSelf];
        }
    }
}


@end
