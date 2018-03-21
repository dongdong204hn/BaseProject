//
//  NIPJSPluginManager.h
//  NIPJSBridge
//
//  Created by Eric on 2017/2/7.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @class NIPJSPluginManager
 * 用来管理本地插件的类
 */
@interface NIPJSPluginManager : NSObject

/**
 * 根据配置文件初始化插件管理器
 */
- (instancetype)initWithConfigFile:(NSString *)file;

/**
 * 根据传入文件路径下的配置文件重置插件管理器
 */
- (void)setupWithConfigFile:(NSString *)file;

/**
 * 根据PluginName获取该插件的实例对象
 */
- (id)getPluginInstanceByPluginName:(NSString *)pluginName;


/**
 * 根据plugin的showMethod获取Native对应的SEL
 */
- (NSString *)realSELForShowMethod:(NSString *)showMethod;


/**
 * 获取本地核心JS字符串
 */
- (NSString *)localCoreJSBridgeCode;

@end
