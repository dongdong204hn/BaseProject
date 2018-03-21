//
//  NIPScreenTipView.m
//  NSIP
//
//  Created by 赵松 on 16/12/13.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPScreenTipView.h"
#import "UIView+NIPBasicAdditions.h"
#import "nip_macros.h"
#import "NIPUIFactory.h"


@interface NIPScreenTipView ()

@property (nonatomic, strong) UIView *imageBackView;
@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation NIPScreenTipView
@synthesize showColor = _showColor;

+ (instancetype)tipView {
    return [[NIPScreenTipView alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    frame = [UIApplication sharedApplication].keyWindow.frame;
    self = [super initWithFrame:frame];
    if (self) {
        self.showCancelBtn = YES;
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:_singleTap];
        
        [[UIApplication sharedApplication].delegate.window addSubview:self];
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageBackView  = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_imageBackView];
        _imageBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.0f];
    }
    return self;
}

- (id)initWithImage:(UIImage*)image;
{
    if (self = [super init]) {
        self.tipImage = image;
    }
    return self;
}

- (void)setTipImage:(UIImage *)tipImage {
    if (_tipImage != tipImage) {
        _tipImage = tipImage;
        if (_tipImage) {
            _tipImageView = [[UIImageView alloc] initWithImage:_tipImage];
            while (_tipImageView.width > SCREEN_WIDTH || _tipImageView.height > SCREEN_WIDTH) {
                _tipImageView.size = CGSizeMake(_tipImageView.width/2.f, _tipImageView.height/2.f);
            }
            [self addSubview:_tipImageView];
            [_tipImageView makeCenter];
        }
    }
    if (_tipImage) {
        if (self.showCancelBtn) {
            if (!_closeBtn) {
                _closeBtn = [NIPUIFactory buttonWithImage:[UIImage imageNamed:@"main_activity_close"] target:self selector:@selector(cancel)];
                [self addSubview:_closeBtn];
            }
            _closeBtn.top = _tipImageView.top;
            _closeBtn.right = (_tipImageView.width > SCREEN_WIDTH? SCREEN_WIDTH: _tipImageView.right);
        } else {
            [_closeBtn removeFromSuperview];
        }
    }
}

- (void)setShowColor:(UIColor *)showColor {
    _showColor = showColor;
    if (self.isShow) {
        _imageBackView.backgroundColor = _showColor;
    }
}

- (UIColor *)showColor {
    if (!_showColor) {
        _showColor = [[UIColor blackColor] colorWithAlphaComponent:.8f];
    }
    return _showColor;
}

#pragma mark - action

- (void)show {
    self.isShow = YES;
    _imageBackView.backgroundColor = self.showColor;
}

- (void)didTap:(id)sender {
    if (self.didTapBlock) {
        //        [self jumpToWeb];
        self.didTapBlock();
    }
    [self cancel];
}

- (void)cancel {
    self.isShow = NO;
    [self removeFromSuperview];
}

//- (void)jumpToWeb {
//    [[NTURLHandler sharedHandler] openStringUrl:_jumpUrlString
//                                   inController:self.parentViewController];
//}

- (void)resizeForActivity {
    [_tipImageView centerVertical];
    if (!_closeBtn) {
        _closeBtn = [NIPUIFactory buttonWithImage:[UIImage imageNamed:@"main_activity_close"] target:self selector:@selector(cancel)];
        [self addSubview:_closeBtn];
        _closeBtn.top = _tipImageView.top;
        _closeBtn.right = (_tipImageView.width > SCREEN_WIDTH? SCREEN_WIDTH: _tipImageView.right);
    }
}

@end
