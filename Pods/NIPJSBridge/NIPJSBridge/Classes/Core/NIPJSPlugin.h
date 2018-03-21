//
//  NIPJSPlugin.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "NIPJSCommandDelegate.h"
#import "NIPJSPluginResult.h"


@class NIPJSService;

/**
 * @class NIPJSPlugin
 * 产检基类，本地自定义插件由此继承
 */

@interface NIPJSPlugin : NSObject

@property (nonatomic, weak) NIPJSService *bridgeService;  // 在bridgeService中提供对webview和controller的访问
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) id<NIPJSCommandDelegate> commandDelegate;
@property (nonatomic, assign) BOOL isReady;

/**
 * 插件不自己初始化，如果需要初始化插件内容，调用此方法
 */
- (void)pluginInitialize;

/**
 * 停止插件使用
 */
- (void)stopPlugin;

/**
 * 监听Bridge服务开启
 */
- (void)onConnect:(NSNotification *)notification;

/**
 * 监听Bridge服务关闭
 */
- (void)onClose:(NSNotification *)notification;

/**
 * 监听Bridge绑定的webview加载完毕事件
 */
- (void)onWebViewFinishLoad:(NSNotification *)notification;

/**
 *直接在插件中向webView发送JS执行代码
 */
- (NSString *)writeJavascript:(NSString *)javascript;
@end
