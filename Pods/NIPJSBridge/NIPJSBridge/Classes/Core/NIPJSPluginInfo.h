//
//  NIPJSPluginInfo.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIPJSPlugin, NIPJSExportDetail;

/**
 * @class NIPJSPluginInfo
 * 插件的详细描述配置
 */
@interface NIPJSPluginInfo : NSObject

@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic, strong) NSString *pluginClass;
@property (nonatomic, strong) NSMutableDictionary *exports;
@property (nonatomic, strong) NIPJSPlugin *instance;


/**
 * 根据传入的字典初始化插件信息
 */
- (instancetype)initWithPluginInfo:(NSDictionary *)pluginInfo;

/**
 *根据JSAPI调用方法名获取实际的selector method方法；
 */
- (NIPJSExportDetail *)getDetailByShowMethod:(NSString *)showMethod;

@end
