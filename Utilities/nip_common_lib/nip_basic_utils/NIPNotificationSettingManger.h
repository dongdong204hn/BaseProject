//
//  NIPNotificationMnager.h
//  NSIP
//
//  Created by bjjiachunhui on 2017/7/27.
//  Copyright © 2017年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^NIPReplyBlock)(bool);

@interface NIPNotificationSettingManger : NSObject


+ (void)hasDeviceOpenPushNotificationSettingWithReplyBlock:(NIPReplyBlock)block;
+ (void)jumpToDevicePushSetting;
@end
