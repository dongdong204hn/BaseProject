//
//  NIPDevice.h
//  
//
//  Created by Eric on 2017/4/24.
//
//

#import "NIPJSPlugin.h"

@class NIPJSInvokedURLCommand;

@interface NIPDevice : NIPJSPlugin


/**
 *@func 获取设备信息
 */
- (void)getDeviceInfo:(NIPJSInvokedURLCommand *)command;

/**
 *@func 获取客户端信息
 */
- (void)getClientInfo:(NIPJSInvokedURLCommand *)command;

/**
 *@func 获取当前网络状况
 */
- (void)getNetworkInfo:(NIPJSInvokedURLCommand *)command;

/**
 *@func 获取webview类型
 */
- (void)getWebViewType:(NIPJSInvokedURLCommand *)command;



/**
 *@func 连接wifi
 */
- (void)connectToWiFi:(NIPJSInvokedURLCommand *)command;


/**
 *@func 设置屏幕是否常亮
 */
- (void)setScreenStatus:(NIPJSInvokedURLCommand *)command;


@end
