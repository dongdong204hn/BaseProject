//
//  NIPFileService.m
//  trainTicket
//
//  Created by 赵松 on 15/11/5.
//  Copyright © 2015年 netease. All rights reserved.
//

#import "NIPFileService.h"
#include <CommonCrypto/CommonDigest.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdint.h>
#include <stdio.h>
#import "nip_macros.h"

@implementation NIPFileService

#pragma mark - Public Methods

#pragma mark Get SandBox Home/Document/Library/Cache/Temp Directory

+ (NSString *)homeDirectory
{
    return NSHomeDirectory();
}

+ (NSString *)documentDirectory
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [docPaths objectAtIndex:0];
}

+ (NSString *)libraryDirectory
{
    NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [libPaths objectAtIndex:0];
}

+ (NSString *)libraryCacheDirectory
{
    NSArray *cacPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [cacPaths objectAtIndex:0];
}

+ (NSString *)tempDirectory
{
    return NSTemporaryDirectory();
}

#pragma mark Bundle resource/file/identifier/info.plist/(object for key in info.plist)

+ (NSString *)bundleResourceDirectory
{
    return [[NSBundle mainBundle] resourcePath];
}

+ (NSString *)bundleFile:(NSString *)fileName withType:(NSString *)type {
    return [[NSBundle mainBundle] pathForResource:fileName ofType:type];
}

+ (NSString *)bundleIdentifier
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)objectForInfoDictionaryKey:(NSString *)key
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

#pragma mark File&Folder Feature

+ (BOOL)fileExistAtPath:(NSString *)filePath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    return existed && !isDir;
}

+ (NSArray *)fileNameListOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSRange range;
    range.location = 0;
    NSInteger typeLength = [type length] + 1;
    for (NSString *filename in tmplist) {
        if ([[filename pathExtension] isEqualToString:type]) {
            range.length = filename.length - typeLength;
            NSString *nameWithoutExtension = [filename substringWithRange:range];
            [filenamelist addObject:nameWithoutExtension];
        }
    }
    return filenamelist;
}

+ (BOOL)folderExistAtPath:(NSString *)folderPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    return existed && isDir;
}

+ (CGFloat)sizeAtPath:(NSString *)folderPath
{
    BOOL isDir = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath isDirectory:&isDir])
        return 0;
    long long folderSize = 0;
    if (isDir) {
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
        NSString *fileName;
        while (fileName = [childFilesEnumerator nextObject]) {
            NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
            if (!notEmptyArray([manager subpathsAtPath:fileAbsolutePath])) {
                folderSize += [self fileSizeAtPath:fileAbsolutePath];
            }
        }
    }
    else {
        folderSize += [self fileSizeAtPath:folderPath];
    }

    return folderSize / (1024.0 * 1024.0);
}

/**
 *  get file size
 *
 *  @param filePath path of file
 *
 *  @return 单个文件的大小，单位是字节
 */
+ (long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

#pragma mark File Operation.

+ (BOOL)createFileAtPath:(NSString *)filePath withData:(NSData *)contentData {
    if ([self fileExistAtPath:filePath]) {
        return NO;
    }
    BOOL hasFolder = YES;
    NSString *folderPath = [filePath stringByDeletingLastPathComponent];
    if (![self folderExistAtPath:folderPath]) {
        hasFolder = [self createFolder:folderPath];
    }
    if (hasFolder) {
        NSFileManager *manager = [NSFileManager defaultManager];
        return [manager createFileAtPath:filePath contents:contentData attributes:nil];
    }
    return NO;
}

+ (NSData *)contentsAtPath:(NSString *)filePath {
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
}

- (BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2 {
    return [[NSFileManager defaultManager] contentsEqualAtPath:path1 andPath:path2];
}

/**
 * @description   write objects to absolute file path.
 * @param         object   object to written
 *                path     absolute file path
 * @return        BOOL .
 */
+ (BOOL)writeObject:(id)object toFile:(NSString *)filePath
{
    if ([object respondsToSelector:@selector(writeToFile:atomically:)]) {
        return [object writeToFile:filePath atomically:YES];
    }
    return NO;
}

+ (BOOL)writeString:(NSString *)string toFile:(NSString *)filePath
{
    return [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


/**
 * @description   delete object to absolute file path.
 * @param         object   object to delete
 *                path     absolute file path
 * @return        BOOL .
 */
+ (BOOL)removeFileAtPath:(NSString *)filePath
{
    BOOL res;
    if ([NIPFileService fileExistAtPath:filePath] == NO) {
        return YES;
    }

    NSError *error = nil;
    res = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];

    if (!error && res) {
        return YES;
    }
    return NO;
}

+ (BOOL)moveFile:(NSString *)filePath toPath:(NSString *)toPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (existed && !isDir) {
        NSString *toFolderPath = [toPath stringByDeletingLastPathComponent];
        NSError *error = nil;
        existed = [fileManager fileExistsAtPath:toFolderPath isDirectory:&isDir];
        if (existed) {
            if (!isDir) {
                return NO;
            }
        } else {
            [fileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (error) {
            return NO;
        }
        
        BOOL isSuccess = [fileManager moveItemAtPath:filePath toPath:toPath error:&error];
        if (isSuccess && !error) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)copyFile:(NSString *)filePath toPath:(NSString *)toPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (existed && !isDir) {
        NSString *toFolderPath = [toPath stringByDeletingLastPathComponent];
        NSError *error = nil;
        existed = [fileManager fileExistsAtPath:toFolderPath isDirectory:&isDir];
        if (existed) {
            if (!isDir) {
                return NO;
            }
        } else {
            [fileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (error) {
            return NO;
        }
        
        BOOL isSuccess = NO;
        // 目标文件已存在要先删除，否则会导致拷贝失败
        if ([fileManager fileExistsAtPath:toPath isDirectory:&isDir]) {
            isSuccess = [self removeFileAtPath:toPath];
            if (!isSuccess) {
                return NO;
            }
        }
        isSuccess = [fileManager copyItemAtPath:filePath toPath:toPath error:&error];
        if (isSuccess && !error) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Folder Operation.
+ (BOOL)createFolder:(NSString *)folderPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!(isDir && existed)) {
        return [fileManager createDirectoryAtPath:folderPath
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil];
    }
    return NO;
}

+ (BOOL)removeFolder:(NSString *)folderPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (existed && isDir) {
        BOOL retVal = [fileManager removeItemAtPath:folderPath error:NULL];
        if (retVal) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)subpathsOfFolder:(NSString *)folderPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];

    if (existed == YES && isDir == YES) {
        NSError *error = nil;
        NSArray *result = [fileManager subpathsOfDirectoryAtPath:folderPath error:&error];
        
        if (!error) {
            return result;
        }
    }
    return nil;
}

+ (NSArray *)subpathsTestOfFolder:(NSString *)folderPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if (existed == YES && isDir == YES) {
        NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:folderPath];
        return [dirEnum allObjects];
    }
    return nil;
}

+ (BOOL)copyFolderFrom:(NSString *)sourcePath to:(NSString *)destinationPath
{
    if (![self folderExistAtPath:sourcePath]) {
        return NO;
    }
    
    // 目标文件夹存在要先删除，否则会导致拷贝失败
    if ([self folderExistAtPath:destinationPath]) {
        BOOL hasRemoved = YES;
        hasRemoved = [self removeFolder:destinationPath];
        if (!hasRemoved) {
            return NO;
        }
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isSuccess = [fm copyItemAtPath:sourcePath toPath:destinationPath error:&error];

    if (isSuccess && !error) {
        return YES;
    }
    return NO;
}

+ (BOOL)moveFolder:(NSString *)folderPath toPath:(NSString *)toPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (existed && isDir) {
        NSError *error = nil;
        existed = [fileManager fileExistsAtPath:toPath isDirectory:&isDir];
        if (existed) {
            if (!isDir) {
                return NO;
            }
        } else {
            [fileManager createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (error) {
            return NO;
        }
        
        BOOL isSuccess = [fileManager moveItemAtPath:folderPath toPath:toPath error:&error];
        if (isSuccess && !error) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - NSFileHandle - Change File Content
#pragma mark Append Content.
+ (void)appendData:(NSData *)data toEndOfFile:(NSString *)filePath {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

+ (void)appendData:(NSData *)data toFile:(NSString *)filePath withOffset:(unsigned long long)offset {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToFileOffset:offset];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

/**
 *  Set the length of file offset B
 *
 *  @param filePath file name
 *  @param offset   content length. unit B
 */
+ (void)truncateFile:(NSString *)filePath atOffset:(unsigned long long)offset {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle truncateFileAtOffset:offset];
    [fileHandle closeFile];
}

#pragma mark Copy Content.
+ (BOOL)copyDataFromFile:(NSString *)sourcePath toFile:(NSString *)desctinationPath {
    NSFileHandle *infile, *outfile; //输入文件、输出文件
    NSData *buffer; //读取的缓冲数据
    
    if (![self createFileAtPath:desctinationPath withData:nil]) {
        
        return NO;
        
    }
    
    infile = [NSFileHandle fileHandleForReadingAtPath:sourcePath]; //创建读取源路径文件
    if (!infile) {
        return NO;
    }
    
    outfile = [NSFileHandle fileHandleForWritingAtPath:desctinationPath]; //创建病打开要输出的文件
    if (!outfile) {
        return NO;
    }
    
    [outfile truncateFileAtOffset:0]; //将输出文件的长度设为0
    buffer = [infile readDataToEndOfFile];  //读取数据
    //    or:buffer = [infile availableData];
    [outfile writeData:buffer];  //写入输入
    [infile closeFile];
    [outfile closeFile];
    return YES;
}


#pragma mark -
#pragma mark Hash File
//https://github.com/JoeKun/FileMD5Hash

// Constants
static const size_t FileHashDefaultChunkSizeForReadingData = 4096;

// Function pointer types for functions used in the computation
// of a cryptographic hash.
typedef int (*FileHashInitFunction)(uint8_t *hashObjectPointer[]);
typedef int (*FileHashUpdateFunction)(uint8_t *hashObjectPointer[], const void *data, CC_LONG len);
typedef int (*FileHashFinalFunction)(unsigned char *md, uint8_t *hashObjectPointer[]);

// Structure used to describe a hash computation context.
typedef struct _FileHashComputationContext {
    FileHashInitFunction initFunction;
    FileHashUpdateFunction updateFunction;
    FileHashFinalFunction finalFunction;
    size_t digestLength;
    uint8_t **hashObjectPointer;
} FileHashComputationContext;

#define FileHashComputationContextInitialize(context, hashAlgorithmName)               \
    CC_##hashAlgorithmName##_CTX hashObjectFor##hashAlgorithmName;                     \
    context.initFunction = (FileHashInitFunction)&CC_##hashAlgorithmName##_Init;       \
    context.updateFunction = (FileHashUpdateFunction)&CC_##hashAlgorithmName##_Update; \
    context.finalFunction = (FileHashFinalFunction)&CC_##hashAlgorithmName##_Final;    \
    context.digestLength = CC_##hashAlgorithmName##_DIGEST_LENGTH;                     \
    context.hashObjectPointer = (uint8_t **)&hashObjectFor##hashAlgorithmName

+ (NSString *)hashOfFileAtPath:(NSString *)filePath withComputationContext:(FileHashComputationContext *)context
{
    NSString *result = nil;
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean) false);
    CFReadStreamRef readStream = fileURL ? CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL) : NULL;
    BOOL didSucceed = readStream ? (BOOL)CFReadStreamOpen(readStream) : NO;
    if (didSucceed) {

        // Use default value for the chunk size for reading data.
        const size_t chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;

        // Initialize the hash object
        (*context->initFunction)(context->hashObjectPointer);

        // Feed the data to the hash object.
        BOOL hasMoreData = YES;
        while (hasMoreData) {
            uint8_t buffer[chunkSizeForReadingData];
            CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, (CFIndex)sizeof(buffer));
            if (readBytesCount == -1) {
                break;
            }
            else if (readBytesCount == 0) {
                hasMoreData = NO;
            }
            else {
                (*context->updateFunction)(context->hashObjectPointer, (const void *)buffer, (CC_LONG)readBytesCount);
            }
        }

        // Compute the hash digest
        unsigned char digest[context->digestLength];
        (*context->finalFunction)(digest, context->hashObjectPointer);

        // Close the read stream.
        CFReadStreamClose(readStream);

        // Proceed if the read operation succeeded.
        didSucceed = !hasMoreData;
        if (didSucceed) {
            char hash[2 * sizeof(digest) + 1];
            for (size_t i = 0; i < sizeof(digest); ++i) {
                snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
            }
            result = [NSString stringWithUTF8String:hash];
        }
    }
    if (readStream)
        CFRelease(readStream);
    if (fileURL)
        CFRelease(fileURL);
    return result;
}

+ (NSString *)md5HashOfFileAtPath:(NSString *)filePath
{
    FileHashComputationContext context;
    FileHashComputationContextInitialize(context, MD5);
    return [self hashOfFileAtPath:filePath withComputationContext:&context];
}

+ (NSString *)sha1HashOfFileAtPath:(NSString *)filePath
{
    FileHashComputationContext context;
    FileHashComputationContextInitialize(context, SHA1);
    return [self hashOfFileAtPath:filePath withComputationContext:&context];
}

+ (NSString *)sha512HashOfFileAtPath:(NSString *)filePath
{
    FileHashComputationContext context;
    FileHashComputationContextInitialize(context, SHA512);
    return [self hashOfFileAtPath:filePath withComputationContext:&context];
}

#pragma mark - application
#pragma mark Sandbox
/**
 *  获取应用缓存数据的大小，单位M
 *
 *  @return 应用缓存数据的大小，单位M
 */
+ (CGFloat)getCacheCapacity {
    NSString *folderPath = [self libraryCacheDirectory];
    folderPath = [folderPath stringByAppendingPathComponent:[self bundleIdentifier]];
    
    return [self sizeAtPath:folderPath];
}

+ (void)removeAllCachedResponses {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


@end
