//
//  NIPJSSensor.h
//  NIPJSBridge
//
//  Created by Eric on 2017/6/19.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPlugin.h"

@class NIPJSInvokedURLCommand;

@interface NIPJSSensor : NIPJSPlugin

- (void)listenToMic:(NIPJSInvokedURLCommand *)command;

- (void)listenToMotion:(NIPJSInvokedURLCommand *)command;

@end
