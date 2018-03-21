//
//  LDMD5Utils.m
//  NetEasePatch
//
//  Created by ss on 15/9/24.
//  Copyright (c) 2015年 Hui Pang. All rights reserved.
//

#import "LDMD5Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LDMD5Utils

+ (NSString *)fileMD5:(NSString *)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (handle == nil) return @"ERROR GETTING FILE MD5";  // file didnt exist

    CC_MD5_CTX md5;

    CC_MD5_Init(&md5);

    BOOL done = NO;
    while (!done) {
        NSData *fileData = [handle readDataOfLength:256];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if ([fileData length] == 0) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *s = [NSString
        stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                         digest[0], digest[1], digest[2], digest[3], digest[4], digest[5],
                         digest[6], digest[7], digest[8], digest[9], digest[10], digest[11],
                         digest[12], digest[13], digest[14], digest[15]];
    return s;
}

+ (NSDictionary *)dictionaryMD5:(NSString *)path
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    for (NSString *fileName in fileList) {
        NSString *filePath =
            [path stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
        BOOL isDic = NO;
        BOOL exist = [fileManager fileExistsAtPath:filePath isDirectory:&isDic];
        if (exist && isDic) {
            [result setValuesForKeysWithDictionary:[LDMD5Utils dictionaryMD5:filePath]];
        } else if (exist) {
            if ([fileName hasPrefix:@"."]) {
                continue;
            }
            if ([fileName hasSuffix:@"lua"]) {
                NSString *md5 = [LDMD5Utils fileMD5:filePath];
                [result setValue:@"lua" forKey:md5];
            } else if ([fileName hasSuffix:@"js"]) {
                NSString *md5 = [LDMD5Utils fileMD5:filePath];
                [result setValue:@"js" forKey:md5];
            }
        }
    }
    return result;
}

+ (BOOL)verifyDictionary:(NSDictionary *)dic1
     isEqualToDictionary:(NSDictionary *)dic2
           withExtension:(NSString *)extension
{
    NSArray *keys1 = [dic1 allKeys];
    NSArray *keys2 = [dic2 allKeys];
    for (NSString *key in keys1) {
        NSString *value1 = [dic1 objectForKey:key];
        NSString *value2 = [dic2 objectForKey:key];
        if ([value1 isEqualToString:extension]) {
            if (value2 && [value2 isEqualToString:value1]) {
                continue;
            } else {
                return NO;
            }
        } else {
            continue;
        }
    }
    for (NSString *key in keys2) {
        NSString *value1 = [dic1 objectForKey:key];
        NSString *value2 = [dic2 objectForKey:key];
        if ([value2 isEqualToString:extension]) {
            if (value1 && [value1 isEqualToString:value2]) {
                continue;
            } else {
                return NO;
            }
        } else {
            continue;
        }
    }
    return YES;
}

@end
