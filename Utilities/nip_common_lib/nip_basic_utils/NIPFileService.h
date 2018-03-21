//
//  NIPFileService.h
//  trainTicket
//
//  Created by 赵松 on 15/11/5.
//  Copyright © 2015年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Public Interface

/**
 *  提供文件基本操作
 */
@interface NIPFileService : NSObject

#pragma mark - Public Methods

#pragma mark Get Sandbox Home/Document/Library/Cache/Temp Directory
+ (NSString *)homeDirectory;
+ (NSString *)documentDirectory;
+ (NSString *)libraryDirectory;
+ (NSString *)libraryCacheDirectory;
+ (NSString *)tempDirectory;

#pragma mark Bundle resource/file/identifier/info.plist/(object for key in info.plist)
+ (NSString *)bundleResourceDirectory;
+ (NSString *)bundleFile:(NSString *)fileName withType:(NSString *)type;
+ (NSString *)bundleIdentifier;
+ (NSString *)objectForInfoDictionaryKey:(NSString *)key;

#pragma mark File&Folder Feature
+ (BOOL)fileExistAtPath:(NSString *)fileName;
+ (NSArray *)fileNameListOfType:(NSString *)type fromDirPath:(NSString *)dirPath;
+ (BOOL)folderExistAtPath:(NSString *)folderPath;
/**
 *  get file size
 *
 *  @param filePath path of file
 *
 *  @return 单个文件的大小，单位是字节
 */
+ (long long)fileSizeAtPath:(NSString *)filePath;
/**
 *  获取文件或者文件夹的大小，单位M
 *
 *  @param folderPath 文件或文件夹的路径
 *
 *  @return 文件或者文件夹的大小，单位M
 */
+ (CGFloat)sizeAtPath:(NSString*) folderPath;

#pragma mark File Operation.
+ (BOOL)createFileAtPath:(NSString *)filePath withData:(NSData *)contentData;
+ (NSData *)contentsAtPath:(NSString *)filePath;
- (BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2;
+ (BOOL)writeObject:(id)object toFile:(NSString *)filePath;
+ (BOOL)writeString:(NSString *)string toFile:(NSString *)filePath;
+ (BOOL)removeFileAtPath:(NSString *)filePath;
+ (BOOL)moveFile:(NSString *)filePath toPath:(NSString *)toPath;
+ (BOOL)copyFile:(NSString *)filePath toPath:(NSString *)toPath;

#pragma mark Folder Operation.
+ (BOOL)createFolder:(NSString *)folderPath;
+ (BOOL)removeFolder:(NSString *)folderPath;
+ (NSArray *)subpathsOfFolder:(NSString *)folderPath;
+ (NSArray *)subpathsTestOfFolder:(NSString *)folderPath;
+ (BOOL)copyFolderFrom:(NSString *)sourcePath to:(NSString *)destinationPath;
+ (BOOL)moveFolder:(NSString *)folderPath toPath:(NSString *)toPath;

#pragma mark - NSFileHandle - Change File Content
#pragma mark Append Content.
+ (void)appendData:(NSData *)data toEndOfFile:(NSString *)filePath;
+ (void)appendData:(NSData *)data toFile:(NSString *)filePath withOffset:(unsigned long long)offset;
+ (void)truncateFile:(NSString *)filePath atOffset:(unsigned long long)offset;

#pragma mark Copy Content.
+ (BOOL)copyDataFromFile:(NSString *)sourcePath toFile:(NSString *)desctinationPath;

#pragma mark -
#pragma mark Hash File
+ (NSString *)md5HashOfFileAtPath:(NSString *)filePath;
+ (NSString *)sha1HashOfFileAtPath:(NSString *)filePath;
+ (NSString *)sha512HashOfFileAtPath:(NSString *)filePath;

#pragma mark - application
#pragma mark Sandbox
/**
 *  获取应用缓存数据的大小，单位M
 *
 *  @return 应用缓存数据的大小，单位M
 */
+ (CGFloat)getCacheCapacity;

/**
 *  清除全部NSURLCache缓存数据
 */
+ (void)removeAllCachedResponses;

@end
