//
//  UIViewController+TopMostViewController.m
//  NSIP
//
//  Created by Eric on 16/10/8.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "UIViewController+TopMostViewController.h"
#import "AppDelegate.h"

@implementation UIViewController (TopMostViewController)

+ (UIViewController *)topmostViewController
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewContoller = appDelegate.currentTabController;
    //当前显示哪个tab页
    UINavigationController *rootNavController = (UINavigationController *) [(UITabBarController*)rootViewContoller selectedViewController];
    if (!rootNavController) {
        return nil;
    }
    
    UINavigationController *navController = rootNavController;
    while ([navController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [navController topViewController];
        if ([topViewController isKindOfClass:[UINavigationController class]]) { //顶层是个导航控制器，继续循环
            navController = (UINavigationController *) topViewController;
        } else {
            //是否有弹出presentViewControllr;
            UIViewController *presentedViewController = topViewController.presentedViewController;
            while (presentedViewController) {
                topViewController = presentedViewController;
                if ([topViewController isKindOfClass:[UINavigationController class]]) {
                    break;
                } else {
                    presentedViewController = topViewController.presentedViewController;
                }
            }
            navController = (UINavigationController *) topViewController;
        }
    }
    return (UIViewController *) navController;
}

@end
