//
//  NIPNotificationManager.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPNotificationManager.h"
#import "UILocalNotification+NIPBasicAdditions.h"
#import "NSDate+NIPBasicAdditions.h"
#import "nip_macros.h"

@implementation NTNotificationBuilder

- (UILocalNotification *)build {
    NSAssert(self.fireDate, @"时间必须指定");
    NSAssert(self.message, @"消息内容必须指定");
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate= self.fireDate;
    if ([localNotif respondsToSelector:@selector(setAlertTitle:)]) {
        localNotif.alertTitle = self.title?:@"";
    }
    localNotif.alertBody = self.message;
    localNotif.timeZone = self.timeZone?: [NSTimeZone defaultTimeZone];
    localNotif.alertAction = self.alertAction?: NSLocalizedString(@"确定", @"alertAction");
    localNotif.soundName = self.soundName?: UILocalNotificationDefaultSoundName;
    if (self.repeatInterval > 0) {
        localNotif.repeatInterval = self.repeatInterval;
    }
    if (self.applicationIconBadgeNumber > 0) {
        localNotif.applicationIconBadgeNumber = self.applicationIconBadgeNumber;
    }
    
    if (self.userInfo) {
        localNotif.userInfo = self.userInfo;
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (self.name) {
            [userInfo setValue:self.name forKey:@"key"];
        }
        [userInfo setValue:(self.title?:@"") forKey:@"title"];
        [userInfo setValue:(self.url?:@"") forKey:@"url"];
        [userInfo setValue:@{@"alert":self.message} forKey:@"aps"];
        localNotif.userInfo = userInfo;
    }
    
    return localNotif;
}

@end

@implementation NIPNotificationManager

+ (void)createLocalNotificationWithBuilder:(NTNotificationBuilderBlock)block {
    NSParameterAssert(block);
    NTNotificationBuilder *builder = [[NTNotificationBuilder alloc] init];
    block(builder);
    UILocalNotification *localNotif = [builder build];
    if (localNotif) {
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}

+ (void)cancelLocalNotification:(NSString *)name {
    UILocalNotification *noti = [self notificationNamed:name];
    if (noti) {
        [noti cancel];
    }
}

+ (UILocalNotification *)notificationNamed:(NSString *)name {
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    if (notEmptyArray(localArray)) {
        for (UILocalNotification *noti in localArray) {
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:@"key"];
                if ([inKey isEqualToString:name]) {
                    return noti;
                }
            }
        }
    }
    return nil;
}

+ (NSInteger)remoteNotificationTypes {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
    } else {
        return [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    }
}

@end
