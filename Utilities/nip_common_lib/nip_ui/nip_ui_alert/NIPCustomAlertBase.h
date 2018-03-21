//
//  NIPCustomAlertBase.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZBCustomAlertDismissBlock)(NSUInteger buttonIndex);

typedef NS_ENUM(NSInteger, ZBAlertAnmiationType) {
    ZBAlertAnmiationNone,
    ZBAlertAnmiationAlert,
    ZBAlertAnmiationSheet
};

/**
 *  NIPCustomAlertBase是一个完全自定义的UIAlertView,使用者只需要设置contentView
 */
@interface NIPCustomAlertBase : UIWindow

@property (nonatomic, strong) UIView *backgroundView; //默认是一个黑色半透明UIView
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) ZBAlertAnmiationType animationType;
//! 显示时的背景色
@property (nonatomic, strong) UIColor *showColor;
//! 是否已显示
@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, copy) ZBCustomAlertDismissBlock dismissBlock;

- (void)show;
- (void)dismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)willShow;
- (void)didShow;
- (void)willDismiss;
- (void)didDismiss;
@end

