//
//  NIPJSCommandDelegateImpl.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPJSCommandDelegate.h"

@class NIPJSService;

/**
 * 执行URLCommand的回调
 */
@interface NIPJSCommandDelegateImpl : NSObject <NIPJSCommandDelegate>

/**
 * 初始化Command回调
 */
- (id)initWithService:(NIPJSService *)jsService;

@end
