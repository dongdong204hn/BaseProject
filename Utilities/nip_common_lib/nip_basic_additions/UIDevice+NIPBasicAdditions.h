//
//  UIDevice+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UIDevice NTBasicAdditions
 */
@interface UIDevice (NIPBasicAdditions)

#pragma mark - Screen
+ (CGFloat)screenScale;

+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;

+ (BOOL)fourInchScreen;

#pragma mark - System & Device Info
/**
 *  @return 系统主版本号.
 */
+ (NSInteger)systemMainVersion;

/**
 *  @return 设备类别.
 */
+ (NSString *)deviceModel;

//! @return 处理器指令集类型，eg:x86_64
+ (NSString *)getProcessorInfo;

//! @return 获取设备名称 eg:iPhone 6 (A1549/A1586)
+ (NSString *)getDeviceName;

/**
 *  @return 渠道名
 */
+ (NSString *)getChannelString;

/// 电量
+ (CGFloat)batteryLevel;

@end
