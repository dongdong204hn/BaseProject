//
//  NIPJSCommandQueue.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NIPJSService;

/**
 * @class NIPJSCommandQueue
 * 用来存储从HTML页面发过来的调用请求命令
 */
@interface NIPJSCommandQueue : NSObject

@property (nonatomic, assign, readonly) BOOL isExecutingCMD;  //用于判断当前是否在执行调用请求

/**
 * 初始化和销毁CommandQueue
 */
- (instancetype)initWithService:(NIPJSService *)JSService;
- (void)dispose;

/**
 * 从webview截获URL并执行
 */
- (void)executeCommandsFromURLString:(NSString *)URLString;


@end
