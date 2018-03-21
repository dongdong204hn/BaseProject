//
//  NIPopupView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPopupView.h"
#import "UIView+NIPBasicAdditions.h"
#import "NIPTimer.h"

@implementation NIPopupView

- (void)setContentView:(UIView *)contentView {
    [super setContentView:contentView];
    
    if (contentView) {
        self.frame = contentView.frame;
        contentView.frame = self.bounds;
        
        [self addSubview:contentView];
    }
}

+ (void)showContentView:(UIView*)contentView inController:(UIViewController *)controller closeAfter:(NSTimeInterval)seconds {
    NIPopupView *popView = [[self alloc] init];
    [popView setContentView:contentView];
    [popView showInController:controller];
    [popView closeAfterTimeInterval:seconds];
}

@end
