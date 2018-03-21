//
//  NIPNotificationMnager.m
//  NSIP
//
//  Created by bjjiachunhui on 2017/7/27.
//  Copyright © 2017年 netease. All rights reserved.
//

#import "NIPNotificationSettingManger.h"
#import <UserNotifications/UserNotifications.h>

@implementation NIPNotificationSettingManger


+ (void)hasDeviceOpenPushNotificationSettingWithReplyBlock:(NIPReplyBlock)block
{
    if ([[UIDevice currentDevice].systemVersion floatValue]>=10.0f) {
        
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized)
            {
                block(YES);
            }else {
                block(NO);
            }
        }];
    }
    else
    {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (UIUserNotificationTypeNone == setting.types) {
             block(NO);
        }
        else
        {
            block(YES);
        }
    }
}
+ (void)jumpToDevicePushSetting
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        if ([[UIDevice currentDevice].systemVersion floatValue]>=10.0f) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
}
@end
