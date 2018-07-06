//
//  NSString+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  NSString NTBasicAdditions
 */
@interface NSString (NIPBasicAdditions)

#pragma mark - Compare
/**
 *  比较字符串类型的版本大小，各数字的拆分用separate分离，例
 *  NSString *minVer = @"3.0.0";NSString *maxVer = @"5.0.1";
 *  NSString *currVer = @"3.0";  currVer在区间[minVer,maxVer)内
 *  “1.0.0” == @“1.0”，@“1.0.0.0” < @“1.0.2” ,@“1.0.1”<@“1.1” 等case成立
 *
 *  @param anotherString 比较的串
 *  @param separate      分隔符
 *
 *  @return 比较结果
 */
- (NSComparisonResult)compareNumerically:(NSString*)anotherString withSepateString:(NSString *)separate;

#pragma mark - Localization
+ (NSString *)localizedStringForKey:(NSString *)key;

#pragma mark - Format Inspect
/**
 *  若substring为空字符串或nil时, 返回值为YES.
 */
- (BOOL)containsSubstring:(NSString *)substring;

/**
 *  判断字符串中是否只包含空格和换行符.
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 *  判断字符串是否为空或只包含空格.
 */
- (BOOL)isEmptyOrWhitespace;

/// 判断emailAddr是否邮箱帐号
- (BOOL)isEmailAddress;

/// 判断表达式expression是否整体符合正则表达式regex
- (BOOL)isMatchRegex:(NSString *)regex;

/// 判断mobileNum是否手机号
- (BOOL)isMobileNumber;

/// 判断account是否有效的用户名。当前规则：用户名由字母、数字或“_”组成，以字母开头，长度不少于6位，不多于30位
- (BOOL)isAccountName;

/// 判断accountPwd是否有效的密码。当前规则：密码必须且只能包含字母，数字，下划线中的两种或两种以上,6-25位
- (BOOL)isAccountPwd;

/// 判断personName是否有效的密码。当前规则：姓名必须为中文或英文，中文两个字以上，英文3个字符以上
- (BOOL)isPersonName;

/// 判断word是否汉字。
- (BOOL)isChineseWord;

/// 判断identityCard是否身份证。
- (BOOL)isIdentityCard;

/// 通过身份证identityCard判断是否男性
- (BOOL)isMaleByIdentityCard;

/// 通过后缀判断fileName是否是图片名
- (BOOL)isImageFileName;

/// 判断code是否是邮编。
- (BOOL)isPostalCode;

#pragma mark - Encode
/**
 *  对字符串进行url编码.
 */
- (NSString *)URLEncodedString;

/**
 *  对字符串进行url编码（剔除部分保留字符）
 *
 *  @param set 剔除的保留字符，即不对自定set内的字符进行percentescape
 *
 *  @return url编码过的字符串
 */
- (NSString *)URLEncodedStringLeaveUnescapedCharacterSet:(NSCharacterSet *)unescapedCharacterSet;

/**
 *  对字符串进行url解码.
 */
- (NSString *)URLDecodedString;

/**
 *  对字符串进行html编码.
 */
- (NSString *)escapeHTML;

/**
 *  对字符串进行html解码.
 */
- (NSString *)unescapeHTML;

- (NSString *)md5Digest;

- (NSString *)base64Encode;

- (NSString *)base64Decode;

+ (NSString *)nip_StringWithBase64EncodedString:(NSString *)string;

- (NSString *)nip_Base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;

- (NSString *)nip_Base64EncodedString;

- (NSString *)nip_Base64DecodedString;

- (NSData *)nip_Base64DecodedData;

- (NSData *)base16Data;

/**
 *  对字符串进行JavaScript编码.
 */
- (NSString *)javaScriptEscape;

/**
 *  对字符串进行JavaScript解码.
 */
- (NSString *)javaScriptUnescape;

/**
 *  获取字符串的utf8编码字符串
 *
 *  @return 编码字符串
 */
- (NSString *)encodeUTF8;

/**
 *  获取字符串的gb2312字符串
 *
 *  @return 编码字符串
 */
- (NSString *)encodeGB2312;

/** 包含的字母的数目 */
- (NSInteger)letterCount;

/** 包含的数字的数目 */
- (NSInteger)numCount;

/**
 *  判断字符串中是否有gb2312编码中不包含的生僻字
 *
 *  @return 是否有生僻字
 */
- (BOOL)containRarelyUsedWordByEncodeGB2312;

#pragma mark - URL String
- (NSString *)stringByAppendingUrlParameter:(NSString *)param value:(NSString *)value;

- (NSString *)stringByAppendingUrlParameters:(NSDictionary *)params;

/**
 *  @return 返回一个dictionary, 其key-value与原url地址中所有参数-值对一一对应.
 */
- (NSDictionary *)getQueryParameters;
/**
 *  判断字符串是否以http开头.
 */
- (BOOL)isValidHttpURL;


#pragma mark - Extract Content With Rule
/// 从字符串expression中匹配出符合正则表达式regex的部分
- (NSString *)stringMatchRegex:(NSString*)regex;

/**
 *  取email地址"@"之前的部分.
 */
- (NSString *)emailPrefix;

/**
 *  取email地址"@"之后的部分.
 */
- (NSString *)emailSuffix;

/**
 *  去除字符串两端的空格、换行符等不可见的字符.
 */
- (NSString *)stringByTrimming;

/// 隐藏手机号码中间的七位
- (NSString *)hideMiddleMobileNumber;

/// 获取账号的缩略形式。最长显示18位，多了则冒号显示，同时针对邮箱账号做了特殊处理
- (NSString *)abbrAccount;

/// 从身份证号码中提取生日
- (NSDate *)birthdayFromIdCardNo;

/// 从身份证号码中提取性别.男：M ，女：F
- (NSString *)genderFromIdCardNo;


@end
