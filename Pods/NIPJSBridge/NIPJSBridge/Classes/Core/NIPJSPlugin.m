//
//  NIPJSPlugin.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPlugin.h"
#import "NIPJSService.h"

@implementation NIPJSPlugin


#pragma mark - life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _bridgeService = nil;
        _isReady = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onConnect:)
                                                     name:NIPJSBridgeConnectedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onClose:)
                                                     name:NIPJSBridgeDisconnectedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onWebViewFinishLoad:)
                                                     name:NIPJSBridgeWebViewDidFinishLoadNotification
                                                   object:nil];
    }
    return self;
}

- (void)pluginInitialize {
    // override by subclass
}


- (void)stopPlugin {
    self.bridgeService = nil;
    self.isReady = NO;
}


#pragma mark - 监听事件方法

- (void)onConnect:(NSNotification *)notification {
    if (!self.bridgeService)
        self.bridgeService = [notification.userInfo objectForKey:JSBridgeServiceTag];
}



- (void)onClose:(NSNotification *)notification
{
    if (self.bridgeService && self.bridgeService == notification.object) {
        self.bridgeService = nil;
        self.isReady = NO;
        [self stopPlugin];
    }
}

- (void)onWebViewFinishLoad:(NSNotification *)notification
{
    if (self.bridgeService && self.bridgeService == notification.object) {
        self.isReady = YES;
    }
}


#pragma mark - Getters

- (UIViewController *)viewController {
    if (self.bridgeService) {
        return (UIViewController *)self.bridgeService.viewController;
    } else {
        NSAssert(NO, @"the bridge Service is not connected");
        return nil;
    }
}

- (UIWebView *)webView {
    if (self.bridgeService) {
        return (UIWebView *)self.bridgeService.webView;
    } else {
        NSAssert(NO, @"the bridge Service is not connected");
        return nil;
    }
}

- (id<NIPJSCommandDelegate>)commandDelegate {
    if (self.bridgeService) {
        return self.bridgeService.commandDelegate;
    } else {
        NSAssert(NO, @"the bridge Service is not connected");
        return nil;
    }
}

- (NSString *)writeJavascript:(NSString *)javascript
{
    return [self.bridgeService jsEvalIntrnal:javascript];
}


@end
