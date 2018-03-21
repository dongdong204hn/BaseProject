//
//  NIPAppInfo.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/21.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPlugin.h"

@class NIPJSInvokedURLCommand;

@interface NIPAppInfo : NIPJSPlugin


/**
 *@func 通过scheme判断指定应用是否已经安装
 */
- (void)isAppInstalled:(NIPJSInvokedURLCommand *)command;

/**
 *@func 批量查询应用是否已安装
 */
- (void)isAppInstalledBatch:(NIPJSInvokedURLCommand*)command;

/**
 *@func 使用scheme(ios)或者包名（android）启动第三方应用
 */
- (void)launchApp:(NIPJSInvokedURLCommand*)command;

/**
 *@func 带用户状态的启动第三方应用
 */
- (void)launchAppWithTokens:(NIPJSInvokedURLCommand*)command;

/**
 *@func 打开客服页面
 */
- (void)openFeedback:(NIPJSInvokedURLCommand *)command;

/**
 *@func 设置客户端cookie
 */
- (void)setCookie:(NIPJSInvokedURLCommand *)command;


@end
