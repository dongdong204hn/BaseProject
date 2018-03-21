//
//  NIPJSCommandDelegate.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NIPJSPluginResult;

@protocol NIPJSCommandDelegate <NSObject>

/**
 * 封装native的执行结果，并通过callBackId进行JS回调
 */
- (void)sendPluginResult:(NIPJSPluginResult *)result callbackId:(NSString *)callbackId;


@end
