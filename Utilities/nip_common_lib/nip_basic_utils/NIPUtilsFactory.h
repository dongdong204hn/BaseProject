//
//  NIPUtilsFactory.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPUtilsFactory : NSObject

#pragma mark - 数据处理
/**
 *  获取精确的数值
 *
 *  @param dict         原始字典
 *  @param key          数值对应的key
 *  @param defaultValue 默认值
 *
 *  @return 精确的数值
 */
+ (NSDecimalNumber *)decimalNumberFromDictionary:(NSDictionary *)dict ofKey:(NSString *)key defaultValue:(NSString *)defaultValue;

#pragma mark - Device Info ID
/// 获取本地存储的广告标示符 IFA/IDFA (Identifier for Advertisers)。尚未存储的话会先生成，然后同时存到keychain和userdefault
+ (NSString *)idfa;

/// 获取本地存储的商家标示符 IFV/IDFV (Identifier for Vendor)。尚未存储的话会先生成，然后同时存到keychain和userdefault
+ (NSString *)idfv;

/// 获取本地存储的通用唯一标识符（Universally Unique Identifier)。尚未存储的话会先生成，然后同时存到keychain和userdefault
+ (NSString *)uuid;

/// 重新生成广告标示符 IFA/IDFA (Identifier for Advertisers),局限就是应用必须是显示了广告,并且用户可以重置.
+ (NSString *)generateIdfa;

/// 重新生成商家标示符 IFV/IDFV (Identifier for Vendor),局限就是同一vendor下的应用全部删除了,UUID也会重置.
+ (NSString *)generateIdfv;

/// 重新生成通用唯一标识符（Universally Unique Identifier),局限是每次获取到的id都是不同的。
+ (NSString *)generateUuid;

/// 拨打电话
+ (void)callPhoneNum:(NSString *)num;

@end
