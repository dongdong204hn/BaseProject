//
//  NIPJSCommandDelegateImpl.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSCommandDelegateImpl.h"
#import "NIPJSService.h"
#import "NIPJSPluginResult.h"


@interface NIPJSCommandDelegateImpl ()

@property (nonatomic, weak) NIPJSService *bridgeService;
@property (nonatomic, strong) NSRegularExpression *callbackIdPattern;

@end

@implementation NIPJSCommandDelegateImpl

- (instancetype)initWithService:(NIPJSService *)jsService
{
    self = [super init];
    if (self) {
        _bridgeService = jsService;
        _callbackIdPattern = nil;
    }
    return self;
}

/**
 * 验证URL传入的回调函数是否合法
 * 只允许有大小字母、数字、下划线、中划线、小数点组成的callbackID有效
 * @param callbackId 回调函数
 */
- (BOOL)isValidCallbackId:(NSString *)callbackId {
    NSError *error = nil;
    if (callbackId == nil) {
        return NO;
    }
    
    //回调函数的合法pattern
    if (_callbackIdPattern == nil) {
        _callbackIdPattern = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9._-]"
                                                                       options:0
                                                                         error:&error];
        if (error != nil) {
            return NO;
        }
    }
    
    // Disallow if too long or if any invalid characters were found.
    if (([callbackId length] > 100) ||
        [_callbackIdPattern firstMatchInString:callbackId
                                       options:0
                                         range:NSMakeRange(0, [callbackId length])]) {
            return NO;
        }
    return YES;
}


#pragma mark - NIPJSCommandDelegate method

/**
 *@func 执行完plugin之后通过回调函数返回数据
 *@param callbackId 回调函数
 */
- (void)sendPluginResult:(NIPJSPluginResult *)result callbackId:(NSString *)callbackId {
    if (![self isValidCallbackId:callbackId]) {
        NSLog(@"Invalid callback id received by sendPluginResult");
        return;
    }
    
    //将结果转化成json字符串
    NSString *argumentsAsJSON = [result argumentsAsJSON];
    argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *js = @"";
    if ([callbackId intValue] > 0) { //如果callbackId 以数字开头, 为回调函数的index
        js = [js stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",
              [callbackId intValue], argumentsAsJSON];
    } else { //否则为直接调回调函数
        js = [js stringByAppendingFormat:@"window.%@('%@');", callbackId, argumentsAsJSON];
    }
    
    [_bridgeService jsEval:js];
}




@end
