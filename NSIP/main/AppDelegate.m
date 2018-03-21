//
//  AppDelegate.m
//  NSIP
//
//  Created by Eric on 16/9/22.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "AppDelegate.h"
#import "NIPAppTabBarController.h"
#import "NIPURLHandler.h"
#import "Aspects.h"
#import "NIPHomeViewController.h"
#import "NIPUserViewController.h"
#import "NIPNavigationController.h"
#import "NIPImageFactory.h"
#import "NIPUIFactory.h"
#import "nip_macros.h"


#import <UMengUShare/UShareUI/UShareUI.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self configShareInfo];
    [self generateTabController];
    self.window.rootViewController = _currentTabController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)generateTabController {
    NIPHomeViewController *homeViewController = [[NIPHomeViewController alloc] init];
    homeViewController.hidesBottomBarWhenPushed = NO;
    NIPNavigationController *controllerOne = [[NIPNavigationController alloc] initWithRootViewController:homeViewController];
    [NIPUIFactory setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:controllerOne.navigationBar];
    
    NIPBaseViewController *mid = [[NIPBaseViewController alloc] init];
    mid.hidesBottomBarWhenPushed = NO;
    NIPNavigationController *controllerTwo = [[NIPNavigationController alloc] initWithRootViewController:mid];
    mid.title = @"中";
    [NIPUIFactory setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:controllerTwo.navigationBar];
    
    NIPUserViewController *right = [[NIPUserViewController alloc] init];
    right.hidesBottomBarWhenPushed = NO;
    NIPNavigationController *controllerThree = [[NIPNavigationController alloc] initWithRootViewController:right];
    [NIPUIFactory setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:controllerThree.navigationBar];
    
    _currentTabController = [NIPAppTabBarController tabBarControllerWithRootControllers:@[controllerOne, controllerTwo, controllerThree] andIconNames:@[ @"tab_today", @"tab_today_press", @"tab_licai", @"tab_licai_press", @"tab_mine", @"tab_mine_press" ] andTabBarNames:@[@"今日", @"理财", @"我的"]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - 监听用户操作

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0)
    {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan)
            NSLog(@"监听用户操作");
    }
}

#pragma mark - 分享信息配置

- (void)configShareInfo {
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"58734adb75ca356580000e56"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:@"wxdc1e388c3822c80b"
                                       appSecret:@"3baf1193c85774b3fd9d18447d76cab0"
                                     redirectURL:@"http://mobile.umeng.com/social"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ
                                          appKey:@"1105821097"/*设置QQ平台的appID*/
                                       appSecret:nil
                                     redirectURL:@"http://mobile.umeng.com/social"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina
                                          appKey:@"3921700954"
                                       appSecret:@"04b48b094faeb16683c32669824ebdad"
                                     redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    [[UMSocialManager defaultManager] setPlaform: UMSocialPlatformType_YixinSession
                                          appKey:@"yx35664bdff4db42c2b7be1e29390c1a06"
                                       appSecret:nil
                                     redirectURL:@"http://mobile.umeng.com/social"];
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_QQ), @(UMSocialPlatformType_Qzone) ,@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_YixinSession), @(UMSocialPlatformType_YixinTimeLine)]];
}

@end
