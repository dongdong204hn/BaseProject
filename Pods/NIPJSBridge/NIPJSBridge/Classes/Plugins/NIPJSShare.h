//
//  NIPJSShare.h
//  NIPJSBridge
//
//  Created by Eric on 2017/6/19.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPlugin.h"

@class NIPJSInvokedURLCommand;

@interface NIPJSShare : NIPJSPlugin

/*
 *@func  唤起分享面板
 */
-(void)showShareMenu:(NIPJSInvokedURLCommand *)command;


@end
