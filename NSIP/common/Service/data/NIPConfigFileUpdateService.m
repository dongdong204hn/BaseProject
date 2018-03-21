//
//  NIPConfigFileUpdateService.m
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPConfigFileUpdateService.h"
#import "NIPreciousLocalSettings.h"
#import <AFNetworking/AFNetworking.h>
#import <ZipArchive/ZipArchive.h>
#import "nip_macros.h"

@interface NIPConfigFileUpdateService ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSession;
@property (nonatomic, strong) NSString *localConfigDataPath;

@end

@implementation NIPConfigFileUpdateService

+ (instancetype)sharedService {
    static NIPConfigFileUpdateService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initHttpSession];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDir = [paths objectAtIndex:0];
        [self initGlobalTextFilePathWithDocumentDir:documentDir];
        [self initPromptTextFilePathWithDocumentDir:documentDir];
        [self initPageURLsInfoFilePathWithDocumentDir:documentDir];
        
    }
    return self;
}

- (void)initHttpSession {
    _httpSession = [AFHTTPSessionManager new];
}

- (void)initGlobalTextFilePathWithDocumentDir:(NSString *)documentDir {
    BOOL hasGlobalTextPath = [NIPreciousLocalSettings settings].hasGlobalTextPath;
    if (hasGlobalTextPath) {
        _globalTextFilePath = [documentDir stringByAppendingPathComponent:@"globaltext.json"];
    } else {
        _globalTextFilePath = [[NSBundle mainBundle] pathForResource:@"globaltext" ofType:@"json"];
    }
}

- (void)initPromptTextFilePathWithDocumentDir:(NSString *)documentDir {
    BOOL hasPromptFilePath = [NIPreciousLocalSettings settings].hasPromptTextPath;
    if (hasPromptFilePath) {
        _promptTextFilePath = [documentDir stringByAppendingPathComponent:@"prompt.json"];
    } else {
        _promptTextFilePath = [[NSBundle mainBundle] pathForResource:@"prompt" ofType:@"json"];
    }
}

- (void)initPageURLsInfoFilePathWithDocumentDir:(NSString *)documentDir {
    BOOL hasPagesInfoPath = [NIPreciousLocalSettings settings].hasPageURLsInfoPath;
    if (hasPagesInfoPath) {
        _pageURLsInfoFilePath = [documentDir stringByAppendingPathComponent:@"PageURLsInfo.json"];
    } else {
        _pageURLsInfoFilePath = [[NSBundle mainBundle] pathForResource:@"PageURLsInfo" ofType:@"json"];
    }
}


- (void)checkUpdate {
    WEAK_SELF(weakSelf)
    NSURL *URL = /*待定*/[NSURL URLWithString:@""];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [_httpSession downloadTaskWithRequest:request
                                                                          progress:nil
                                                                       destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                           NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
                                                                           return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                       }
                                                                 completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                     if (!error) {
                                                                         NSString *actualPath = [filePath absoluteString];
                                                                         if([actualPath hasPrefix:@"file://"]) {
                                                                             actualPath = [actualPath substringFromIndex:7];
                                                                         }
                                                                         [weakSelf writeDataFromPath:actualPath];
                                                                     }
                                                                 }];
    [downloadTask resume];

}

- (void)writeDataFromPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        ZipArchive *miniZip = [[ZipArchive alloc] init];
        self.localConfigDataPath = [filePath stringByDeletingLastPathComponent];
        if ([miniZip UnzipOpenFile:filePath]) {
            BOOL ret = [miniZip UnzipFileTo:_localConfigDataPath overWrite:YES];
            if (YES == ret) {
                [self redirectConfigFile];
            }
            [miniZip UnzipCloseFile];
        }
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)redirectConfigFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *promptTextFilePath = [self.localConfigDataPath stringByAppendingPathComponent:@"promptText.json"];
    NSString *globalTextFilePath = [self.localConfigDataPath stringByAppendingPathComponent:@"globalText.json"];
    NSString *PageURLsInfoFilePath = [self.localConfigDataPath stringByAppendingPathComponent:@"pageURLs.json"];
    if ([fileManager fileExistsAtPath:promptTextFilePath]) {
        self.promptTextFilePath = promptTextFilePath;
        [NIPreciousLocalSettings settings].hasPromptTextPath = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSIP_CONFIG_NOTIFICATION_KEYWORD object:self userInfo:@{NSIP_CONFIG_NOTIFICATION_KEYWORD : @"prompt.json"}];
    }
    if ([fileManager fileExistsAtPath:globalTextFilePath]) {
        self.globalTextFilePath = globalTextFilePath;
        [NIPreciousLocalSettings settings].hasGlobalTextPath = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSIP_CONFIG_NOTIFICATION_KEYWORD object:self userInfo:@{NSIP_CONFIG_NOTIFICATION_KEYWORD : @"globaltext.json"}];
    }
    if ([fileManager fileExistsAtPath:PageURLsInfoFilePath]) {
        self.PageURLsInfoFilePath = PageURLsInfoFilePath;
        [NIPreciousLocalSettings settings].hasPageURLsInfoPath = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSIP_CONFIG_NOTIFICATION_KEYWORD object:self userInfo:@{NSIP_CONFIG_NOTIFICATION_KEYWORD : @"pageURLs.json"}];
    }
}

@end
