//
//  NIPPinYinUtil.h
//  NSIP
//
//  Created by 赵松 on 16/12/15.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIPHanyuPinyinOutputFormat;

/**
 *  拼音工具类
 */
@interface NIPPinYinUtil : NSObject

//! 获取汉字word的基本格式的拼音字符串 eg:安背驴->anbeilv
+ (NSString *)pinYinStringSimpleOfWord:(NSString *)word;
//! 获取汉字word的复合格式的拼音字符串 eg:安背驴->(ān)(bèi,bēi)(lǘ)
+ (NSString *)pinYinStringComplexOfWord:(NSString *)word;

//! 获取汉字word对应的指定格式的拼音字符串
+ (NSString *)pinYinStringOfWord:(NSString *)word withHanyuPinyinOutputFormat:(NIPHanyuPinyinOutputFormat *)outputFormat;

//! 获取汉字word对应的指定格式的拼音数组
+ (NSArray *)pinYinArrayOfWord:(NSString *)word withHanyuPinyinOutputFormat:(NIPHanyuPinyinOutputFormat *)outputFormat;

//+ (NSString *)pinYinOfWord:(NSString *)word;

/**
 *  <#Description#>
 *
 *  @param pinyin <#pinyin description#>
 *  @param word   <#word description#>
 *
 *  @return <#return value description#>
 */
+ (BOOL)matchPinYin:(NSString*)pinyin withWord:(NSString*)word;

@end
