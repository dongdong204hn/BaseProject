//
//  LDMD5Utils.h
//  NetEasePatch
//
//  Created by ss on 15/9/24.
//  Copyright (c) 2015年 Hui Pang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDMD5Utils : NSObject

/**
 @abstract  计算文件MD5
 @param     path     文件路径
 @return    MD5 String
 */
+ (NSString *)fileMD5:(NSString *)path;

/**
 @abstract  计算路径下文件MD5
 @param     path     文件路径
 @return    Dictionary of MD5 and file extension
 */
+ (NSDictionary *)dictionaryMD5:(NSString *)path;

/**
 @abstract  比较两个文件夹中指定文件类型的MD5
 @return    equal or not
 */
+ (BOOL)verifyDictionary:(NSDictionary *)dic1
     isEqualToDictionary:(NSDictionary *)dic2
           withExtension:(NSString *)extension;

@end
