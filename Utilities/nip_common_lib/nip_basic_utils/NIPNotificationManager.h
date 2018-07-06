//
//  NIPNotificationManager.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - NTCommonService
/**
 *  提供一些工具类方法。逐步取代CommonUtil
 */
@interface NIPNotificationManager : NSObject

@end


#pragma mark - Notification
@class NTNotificationBuilder;

static NSString *const NTTrainPayNotificationKey = @"NTTrainPayNotificationKey";

/// 构建UILocalNotification参数的块
typedef void (^NTNotificationBuilderBlock)(NTNotificationBuilder *builder);

/**
 *  封装本地推送全部参数。其中fireDate和message必填。
 */
@interface NTNotificationBuilder : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *fireDate;
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic, strong) NSString *alertAction;
@property (nonatomic, strong) NSString *soundName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *specialInfo; //提供给特殊通知传递额外信息
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, assign) NSCalendarUnit repeatInterval;
@property (nonatomic, assign) NSInteger applicationIconBadgeNumber;

- (UILocalNotification *)build;

@end

@interface NIPNotificationManager (NIPCommonServiceNotificationFactory)

#pragma mark localNotification
/// 构建本地推送
+ (void)createLocalNotificationWithBuilder:(NTNotificationBuilderBlock)block;

/// 取消指定key的本地推送
+ (void)cancelLocalNotification:(NSString *)name;

#pragma mark remoteNotification
/// 获取远程推送设置
+ (NSInteger)remoteNotificationTypes;


@end
