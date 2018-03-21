//
//  NIPJSService.m
//  NIPJSBridge
//
//  Created by Eric on 2017/2/7.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSService.h"
#import "NIPJSPluginManager.h"
#import "NIPJSCommandQueue.h"
#import "NIPJSCommandDelegateImpl.h"
#import "NIPJSAlertView.h"


NSString * const NIPJSBridgeConnectedNotification = @"NIPJSBridgeConnectedNotification";
NSString * const NIPJSBridgeDisconnectedNotification = @"NIPJSBridgeDisconnectedNotification";
NSString * const NIPJSBridgeWebViewDidFinishLoadNotification = @"NIPJSBridgeWebViewDidFinishLoadNotification";

NSString * const JSBridgeServiceTag = @"NIPJSBridgeService";

NSString * const JSBridgeScheme = @"nipjsbridge";


#define WEAK_SELF(weakSelf) __weak __typeof(self) weakSelf = self;


@interface NIPJSService ()

@property (nonatomic, strong) NIPJSPluginManager *pluginManager;

@property (nonatomic, weak) id<WKNavigationDelegate> originalDelegate;

@end

@implementation NIPJSService


#pragma mark - lifecycle

- (void)dealloc {
    [self disconnect];
    [_commandQueue dispose];
}

- (instancetype)initBridgeServiceWithConfig:(NSString *)configFile {
    self = [super init];
    if (self) {
        _webView = nil;
        _originalDelegate = nil;
        _pluginManager = [[NIPJSPluginManager alloc] initWithConfigFile:configFile];
        _commandQueue = [[NIPJSCommandQueue alloc] initWithService:self];
        _commandDelegate = [[NIPJSCommandDelegateImpl alloc] initWithService:self];
    }
    return self;
}

- (void)readyWithEvent:(NSString *)eventName {
    //加载结束核心JS结束之后通知前端
    NSString *jsReady = [NSString stringWithFormat:@"mapp.execPatchEvent('%@');", eventName];
    [self jsEvalIntrnal:jsReady];
}


#pragma mark - 连接webview

- (void)connect:(WKWebView *)webView withViewController:(id)viewController {
    if (webView == self.webView) {
        return;
    }
    if (self.webView) {
        [self disconnect];
    }
    
    self.viewController = viewController;
    self.webView = webView;
    self.originalDelegate = webView.navigationDelegate;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [self registerKVO];
    
    NSDictionary *userInfo = @{ JSBridgeServiceTag : self };
    [self postNotificationName:NIPJSBridgeConnectedNotification
                        object:self
                      userInfo:userInfo];
}


#pragma mark - 与当前webview断开连接

- (void)disconnect {
    if (self.webView) {
        [self unregisterKVO];
        self.webView.navigationDelegate = self.originalDelegate;
        self.originalDelegate = nil;
        self.webView = nil;
        self.viewController = nil;
        
        [self postNotificationName:NIPJSBridgeDisconnectedNotification
                            object:self
                          userInfo:nil];
    }
}


#pragma mark - 插件信息管理


- (id)getPluginInstanceWithName:(NSString *)pluginName {
    return [_pluginManager getPluginInstanceByPluginName:pluginName];
}


- (NSString *)realSELForShowMethod:(NSString *)showMethod {
    return [_pluginManager realSELForShowMethod:showMethod];
}


#pragma mark - KVO

- (void)registerKVO {
    if (self.webView) {
        [self.webView addObserver:self
                       forKeyPath:@"navigationDelegate"
                          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                          context:nil];
    }
}

- (void)unregisterKVO {
    if (self.webView) {
        [self.webView removeObserver:self forKeyPath:@"navigationDelegate"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id newDelegate = change[@"new"];
    if (object == self.webView &&
        [keyPath isEqualToString:@"navigationDelegate"] &&
        newDelegate != self) {
        self.originalDelegate = newDelegate;
        self.webView.navigationDelegate = self;
    }
}

#pragma mark - 消息通知

- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark - URL处理

- (void)handleURLFromWebview:(NSString *)URLString {
    if (self.webView != nil &&
        [URLString hasPrefix:JSBridgeScheme]) {
        [_commandQueue executeCommandsFromURLString:URLString];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    [self alertWithTitle:@"alert" andMessage:message];
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    [self alertWithTitle:@"confirm" andMessage:message];
    completionHandler(YES);
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (webView == self.webView) {
        NSURL *url = navigationAction.request.URL;
        if ([[url scheme] isEqualToString:JSBridgeScheme]) {
            [self handleURLFromWebview:[url absoluteString]];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            if ([self.originalDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
                [self.originalDelegate webView:webView
               decidePolicyForNavigationAction:navigationAction
                               decisionHandler:decisionHandler];
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (webView == self.webView) {
        if ([self.originalDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
            [self.originalDelegate webView:webView didStartProvisionalNavigation:navigation];
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView == self.webView) {
        NSString *coreJSBridgeCode = [self.pluginManager localCoreJSBridgeCode];
        [self jsEvalIntrnal:coreJSBridgeCode];
//        __block NSString *path = [[NSBundle mainBundle] pathForResource:@"NIPJSBridge.js" ofType:@"txt"];
//        __block NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        WEAK_SELF(weakSelf)
//        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable execResult, NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"NIPJSService failed to jsEvalIntrnal:%@", js);
//            } else {
////                path = [[NSBundle mainBundle] pathForResource:@"CPJSApi.js" ofType:@"txt"];
////                js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
////                [weakSelf.webView evaluateJavaScript:js completionHandler:^(id _Nullable execResult, NSError * _Nullable error) {
        if ([weakSelf.originalDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
            [weakSelf.originalDelegate webView:webView didFinishNavigation:navigation];
        }
        
        [weakSelf postNotificationName:NIPJSBridgeWebViewDidFinishLoadNotification
                                object:weakSelf
                              userInfo:nil];
//                }];
//            }
//            //            dispatch_semaphore_signal(semaphore);
//        }];
        
//        path = [[NSBundle mainBundle] pathForResource:JsApiFile ofType:@"txt"];
//        js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        [self jsMainLoopEval:js];
        
       
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (webView == self.webView) {
        if ([self.originalDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
            [self.originalDelegate webView:webView
                         didFailNavigation:navigation
                                 withError:error];
        }
    }
}


#pragma mark - js执行

- (void)jsEval:(NSString *)js {
    [self performSelectorOnMainThread:@selector(jsEvalIntrnal:) withObject:js waitUntilDone:NO];
}

- (NSString *)jsEvalIntrnal:(NSString *)js {
    if (self.webView) {
        __block NSString *result = nil;
        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable execResult, NSError * _Nullable error) {
            if (error) {
                NSLog(@"NIPJSService failed to jsEvalIntrnal:%@", js);
            } else {
                result = execResult;
            }
        }];
        return result;
    } else {
        return nil;
    }
}


#pragma mark - Alert view

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
    [NIPJSAlertView alertWithTitle:title andMessage:message];
}



@end
