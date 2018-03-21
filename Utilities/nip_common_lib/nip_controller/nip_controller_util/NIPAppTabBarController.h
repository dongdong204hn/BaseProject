//
//  NIPAppTabBarController.h
//  NSIP
//
//  Created by Eric on 16/10/8.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIPAppTabBarController : UITabBarController

@property (nonatomic, strong) UINavigationController *currentNavigationController;

//！ 第一次获取实例时必须通过此方法
+ (instancetype)tabBarControllerWithRootControllers:(NSArray *)controllers andIconNames:(NSArray *)iconNames andTabBarNames:(NSArray *)tabBarNames;

//! 获取当前实例
+ (NIPAppTabBarController *)currentTabBarController;

//! 刷新底部tabbar
//- (void)reloadTabBarWithTabInfoArray:(NSArray*)array;

- (void)popToRootWithTabIndex:(NSInteger)index;

//- (void)showTipAtUserTab:(NSString*)tip withCouponIcon:(BOOL)showIcon;

//! 用来控制是否显示转场动画
@property(nonatomic,assign)BOOL showNavigationAnimation;

@end
