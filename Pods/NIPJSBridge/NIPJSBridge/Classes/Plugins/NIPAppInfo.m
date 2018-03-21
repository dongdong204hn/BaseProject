//
//  NIPAppInfo.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/21.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPAppInfo.h"
#import "NIPJSInvokedURLCommand.h"

@implementation NIPAppInfo


/**
 *@func 通过scheme判断指定应用是否已经安装
 */
- (void)isAppInstalled:(NIPJSInvokedURLCommand*)command {
    NSString *appScheme = [command JSONParamForkey:@"scheme"];
    BOOL isInstalled = [self isAppInstalledWithScheme:appScheme];
    NIPJSPluginResult *pluginResult = [NIPJSPluginResult resultWithStatus:NIPJSCommandStatus_OK
                                                            messageAsBool:isInstalled];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *@func 批量查询应用是否已安装
 */
- (void)isAppInstalledBatch:(NIPJSInvokedURLCommand*)command {
    NSArray *arr_apps = [command JSONParamForkey:@"schemes"];
    NSMutableArray *arr_result = [NSMutableArray array];
    if ([arr_apps isKindOfClass:[NSArray class]]) {
        [arr_apps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isInstalled = [self isAppInstalledWithScheme:obj];
            [arr_result addObject:@(isInstalled)];
        }];
    }
    
    NIPJSPluginResult *pluginResult = [NIPJSPluginResult resultWithStatus:NIPJSCommandStatus_OK
                                                           messageAsArray:arr_result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *@func 使用scheme(ios)或者报名（android）启动第三方应用
 */
- (void)launchApp:(NIPJSInvokedURLCommand*)command {
    NSString *appScheme = [command JSONParamForkey:@"name"];
    NSURL *appSchemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", appScheme]];
    if([[UIApplication sharedApplication] canOpenURL: appSchemeURL]){
        [[UIApplication sharedApplication] openURL:appSchemeURL];
    }
    //nothing to back
}


/**
 *@func 带用户状态的启动第三方应用；
 */
- (void)launchAppWithTokens:(NIPJSInvokedURLCommand*)command {
    NSString *str_jumpurl = [NSString stringWithFormat:@"%@://%@", [command JSONParamForkey:@"appID"],[command JSONParamForkey:@"paramsStr"]];
    
    NSURL *appSchemeURL = [NSURL URLWithString: str_jumpurl];
    if([[UIApplication sharedApplication] canOpenURL: appSchemeURL]){
        [[UIApplication sharedApplication] openURL:appSchemeURL];
    }
    //nothing to back
}


- (void)openFeedback:(NIPJSInvokedURLCommand *)command {
    NSLog(@"openFeedback:%@", command);
//    [[CFURLHandler sharedHandler] openStringUrl:@"cf163://feedback" inController:[UIViewController topmostViewController]];
}


- (void)copy2Clipboard:(NIPJSInvokedURLCommand *)command{
    NSString *content = [command JSONParamForkey:@"content"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = content;
    NIPJSPluginResult *result =  [NIPJSPluginResult resultWithStatus:NIPJSCommandStatus_OK messageAsDictionary:@{@"code":@1}];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    
}

- (void)setCookie:(NIPJSInvokedURLCommand *)command{
   // need to be overrided according to project
}


#pragma mark - common API

- (BOOL)isAppInstalledWithScheme:(NSString *) appScheme {
    NSString *appSchemeURL = [NSString stringWithFormat:@"%@://", appScheme];
    BOOL isInstalled = NO;
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appSchemeURL]]){
        isInstalled = YES;
    }
    
    return isInstalled;
}


@end
