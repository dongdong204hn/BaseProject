//
//  AppDelegate.h
//  NSIP
//
//  Created by Eric on 16/9/22.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIApplication <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,readonly) UITabBarController *currentTabController;

@end

