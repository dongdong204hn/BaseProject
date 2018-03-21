//
//  NSDictionary+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  NSDictionary NTBasicAdditions
 */
@interface NSDictionary (NIPBasicAdditions)

/**
 *  @param defaulValue 若key对应值为空, 则返回此默认值.
 *  
 *  @return 返回key对应值的bool值, 如果值为nil或NSNull, 返回defaultValue.
 */
- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

/**
 *  @param defaulValue 若key对应值为空, 则返回此默认值.
 *
 *  @return 返回key对应值的int值, 如果值为nil或NSNull, 返回defaultValue.
 */
- (int)intForKey:(NSString *)key defaultValue:(int)defaultValue;

/**
 *  @param defaulValue 若key对应值为空, 则返回此默认值.
 *
 *  @return 返回key对应值的integer值, 如果值为nil或NSNull, 返回defaultValue.
 */
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

/**
 *  @param defaulValue 若key对应值为空, 则返回此默认值.
 *
 *  @return 返回key对应值的long值, 如果值为nil或NSNull, 返回defaultValue.
 */
- (long)longForKey:(NSString *)key defaultValue:(long)defaultValue;

/**
 *  @param defaulValue 若key对应值为空, 则返回此默认值.
 *
 *  @return 返回key对应值的double值, 如果值为nil或NSNull, 返回defaultValue.
 */
- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue;

/**
 *  @param defaulValue 若key对应值为空, 则返回此默认值.
 *
 *  @return 返回key对应值的float值, 如果值为nil或NSNull, 返回defaultValue.
 */
- (float)floatForKey:(NSString *)key defaultValue:(float)defaultValue;

/**
 *  @return 返回key对应值的字符串形式, 若值为nil或NSNull, 返回空字符串.
 */
- (NSString *)stringForKey:(NSString *)key;

/**
 *  @return 返回key的对应值, 若值为nil或NSNull, 返回nil.
 */
- (id)validObjectForKey:(NSString *)key;

/**
 *  @return 若key对应值是NSArray, 返回该array; 若key对应值是NSDictionary, 返回该dictionary中所有key的值组成的array, 若该dictionary值为空, 返回空array; 其余情况返回nil.
 */
- (NSArray *)arrayForKey:(NSString *)key;

/**
 *  @return 若key对应值为NString, 根据string长度返回形式为"yyyy-MM-dd HH:mm"或"yyyy-MM-dd HH:mm:ss"的NSDate, 若string无法解析则返回nil; 若key对应值为数字, 则返回以该数字为时间戳对应的NSDate; 其余情况返回nil.
 */
- (NSDate *)dateForKey:(NSString *)key;

/**
 *  讲字典转换为符合URL编码的查询字符串
 */
- (NSString *)convertToQueryString;

/**
 *  讲字典转换为符合xx=xx格式的字符串，不进行URL编码
 */
- (NSString *)convertToQueryStringWithoutURLEncoding;

/**
 *  去除空字符串
 */
- (NSDictionary *)removeEmptyString;


@end

@interface NSMutableDictionary (NTBasicAdditions)

/**
 *  若anObject不是nil, 则将它设为aKey的对应值.
 */
- (void)setValidObject:(id)anObject forKey:(id)aKey;

- (void)setInteger:(NSInteger)value forKey:(id)key;

- (void)setDouble:(double)value forKey:(id)key;

@end
