//
//  NIPScreenTipWindow.m
//  NSIP
//
//  Created by 赵松 on 16/12/13.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPScreenTipWindow.h"
#import "NIPUIFactory.h"
#import "nip_macros.h"
#import "UIView+NIPBasicAdditions.h"

@interface NIPScreenTipWindow ()

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation NIPScreenTipWindow

+ (instancetype)tipView {
    return [NIPScreenTipWindow new];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationType = ZBAlertAnmiationNone;
        self.backgroundColor = [UIColor clearColor];
        self.showColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.8];
        UILabel *label = [NIPUIFactory labelWithText:@"关闭" boldFont:16.0f textColor:[UIColor whiteColor]];
        label.frame = CGRectMake(SCREEN_WIDTH-40, 30, 40, 20);
        [self addSubview:label];
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:_singleTap];
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    [super setContentView:contentView];
    if (self.showCancelBtn) {
        if (!_closeBtn) {
            _closeBtn = [NIPUIFactory buttonWithImage:[UIImage imageNamed:@"main_activity_close"] target:self selector:@selector(cancel)];
            [self addSubview:_closeBtn];
        }
        _closeBtn.top = contentView.top;
        _closeBtn.right = (contentView.width > SCREEN_WIDTH? SCREEN_WIDTH: contentView.right);
    } else {
        [_closeBtn removeFromSuperview];
    }
}

- (void)didTap:(id)sender {
    if (self.didTapBlock) {
//        [self jumpToWeb];
        self.didTapBlock();
    }
    [self cancel];
}

- (void)cancel {
    [self removeGestureRecognizer:_singleTap];
    [self dismissWithButtonIndex:0];
}

//- (void)jumpToWeb {
//    [[NTURLHandler sharedHandler] openStringUrl:_jumpUrlString
//                                   inController:self.parentViewController];
//}

@end
