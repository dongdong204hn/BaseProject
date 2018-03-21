//
//  NIPJSService.h
//  NIPJSBridge
//
//  Created by Eric on 2017/2/7.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "NIPJSCommandDelegate.h"

@class NIPJSCommandQueue;

extern NSString *const NIPJSBridgeConnectedNotification;  // Bridge和webview连接成功的消息
extern NSString *const NIPJSBridgeDisconnectedNotification;  // Bridge和webView断开连接的消息
extern NSString *const NIPJSBridgeWebViewDidFinishLoadNotification;  // 与Bridge连接的WebView加载完毕消息

extern NSString *const JSBridgeServiceTag;  //获取Notification的service Tag

@interface NIPJSService : NSObject <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) id viewController;

@property (nonatomic, strong, readonly) NIPJSCommandQueue *commandQueue;
@property (nonatomic, strong, readonly) id<NIPJSCommandDelegate> commandDelegate;


/**
 * 根据配置文件初始化BridgeService
 * 引用时需要拷贝插件配置文件（PluginConfig.json）文件作为示例编写，初始化时指定文件名
 * 在插件配置文件中指定核心JS的下载地址，本地文件名也必须和这个名保持一致
 */
- (id)initBridgeServiceWithConfig:(NSString *)configFile;

/**
 * 连接webView
 */
- (void)connect:(WKWebView *)webView withViewController:(id)viewController;

/**
 * 与webView断开连接
 */
- (void)disconnect;

/**
 * 通知前端
 */
- (void)readyWithEvent:(NSString *)eventName;

/**
 * 根据pluginName获取plugin的实例
 */
- (id)getPluginInstanceWithName:(NSString *)pluginName;

/**
 * 根据pluginShowMethod获取对应的真实调用方法名
 */
- (NSString *)realSELForShowMethod:(NSString *)showMethod;

- (void)jsEval:(NSString *)js;
- (NSString *)jsEvalIntrnal:(NSString *)js;

@end
