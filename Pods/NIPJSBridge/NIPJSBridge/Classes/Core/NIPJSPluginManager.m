//
//  NIPJSPluginManager.m
//  NIPJSBridge
//
//  Created by Eric on 2017/2/7.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPluginManager.h"
#import "NIPJSPluginInfo.h"
#import "NIPJSExportDetail.h"


static NSString * const JSBridgeCoreFileName = @"NIPJSBridge.js.txt";  //默认JSBridge核心文件名

@interface NIPJSPluginManager ()

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) NSMutableDictionary *pluginDic;
@property (nonatomic, strong) NSString *updateURLString;
@property (nonatomic, strong) NSString *coreBridgeJSFileName;
@property (nonatomic, assign) BOOL isUpdate;

@end

@implementation NIPJSPluginManager


- (instancetype)init {
    if (self = [super init]) {
        _pluginDic = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithConfigFile:(NSString *)file {
    self = [self init];
    if (self) {
        [self setupWithConfigFile:file];
    }
    return self;
}

- (void)setupWithConfigFile:(NSString *)file {
    NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension]
                                                     ofType:[file pathExtension]];
    if (path) {
        NSData *pluginData = [NSData dataWithContentsOfFile:path];
        NSDictionary *pluginInfo = [NSJSONSerialization JSONObjectWithData:pluginData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        // 以更新url的文件作为核心JS文件的命名
        [self resetCoreJSBridgeFileNameWithPluginInfo:pluginInfo];
        [self initializePluginInfosWithPluginInfo:pluginInfo];
    }
}

- (void)resetCoreJSBridgeFileNameWithPluginInfo:(NSDictionary *)pluginInfo {
    self.updateURLString = [pluginInfo objectForKey:@"update"];
    if (_updateURLString != nil &&
        ![_updateURLString isEqualToString:@""]) {
        _coreBridgeJSFileName = [_updateURLString lastPathComponent];
    } else {
        _coreBridgeJSFileName = JSBridgeCoreFileName;
    }
}

- (void)initializePluginInfosWithPluginInfo:(NSDictionary *)pluginInfo {
    [self.pluginDic removeAllObjects];
    NSArray *plugins = [pluginInfo objectForKey:@"plugins"];
    for (NSDictionary *plugin in plugins) {
        NIPJSPluginInfo *info = [[NIPJSPluginInfo alloc] initWithPluginInfo:plugin];
        [self.pluginDic setObject:info forKey:info.pluginName];
    }
}

- (id)getPluginInstanceByPluginName:(NSString *)pluginName {
    NIPJSPluginInfo *pluginInfo = self.pluginDic[pluginName];
    return pluginInfo.instance;
}

- (NSString *)realSELForShowMethod:(NSString *)showMethod {
    __block NSString *realSEL = nil;
    //找到包含showMethod的插件信息
    [self.pluginDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NIPJSPluginInfo*  _Nonnull obj, BOOL * _Nonnull stop) {
        NIPJSExportDetail *exportDetail = [obj getDetailByShowMethod:showMethod];
        if (exportDetail) {
            realSEL = exportDetail.realMethod;
            *stop = YES;
        }
    }];
    
    if (realSEL == nil) {
        realSEL = showMethod;
    }
    
    realSEL = [NSString stringWithFormat:@"%@:", realSEL];
    return realSEL;
}

/**
 * 从本地获取核心JS字符串
 */
- (NSString *)localCoreJSBridgeCode {
    NSError *error = nil;
    NSString *JSBrideCodeStr = @"";
    
    NSString *cachedJSBridgeFilePath = [[self bridgeCacheDir] stringByAppendingFormat:@"/%@", _coreBridgeJSFileName];
    NSString *bundleBridgeFilePath =
    [[NSBundle mainBundle] pathForResource:_coreBridgeJSFileName ofType:nil];
    
    //如果配置了在线更新地址，则从更新地址更新JSBridge的核心和插件JS
    if (_updateURLString != nil &&
        ![_updateURLString isEqualToString:@""]) {
        // debug状态，始终拷贝修改的JS文件
#ifdef DEBUG
        if (![self.fileManager removeItemAtPath:cachedJSBridgeFilePath error:&error]) {
            NSLog(@"delete cache file error: %@", cachedJSBridgeFilePath);
        }
#endif
        // 如果cache无此文件，则从bundle中拷贝过去。
        if (![self.fileManager fileExistsAtPath:cachedJSBridgeFilePath]) {
            if (![self.fileManager copyItemAtPath:bundleBridgeFilePath
                                           toPath:cachedJSBridgeFilePath
                                            error:&error]) {
                NSLog(@"copy error: %@", cachedJSBridgeFilePath);
            }
        }
        
        JSBrideCodeStr = [NSString stringWithContentsOfFile:cachedJSBridgeFilePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    } else { //如果未配置，则直接从本地读取
        JSBrideCodeStr = [NSString stringWithContentsOfFile:bundleBridgeFilePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    }
    return JSBrideCodeStr;
}


#pragma mark - 核心JS文件更新修复

- (NSString *)bridgeCacheDir {
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *JSBridgeCacheDir = [cacheDir stringByAppendingPathComponent:@"_NIP_JSBridge_Cache_"];
    if (![self.fileManager fileExistsAtPath:JSBridgeCacheDir]) {
        BOOL isCreate = [self.fileManager createDirectoryAtPath:JSBridgeCacheDir
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:nil];
        // bundle cache 目录建立不成功，返回不进行拷贝
        if (!isCreate) {
            return @"";
        }
    }
    
    return JSBridgeCacheDir;
}

- (NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}



@end
