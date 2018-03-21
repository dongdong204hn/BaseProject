//
//  NIPURLHandler.h
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPURLHandler.h"

@interface NIPURLHandler (ComponentsDemo)

///**
// *  获取NIPURLHandler单例
// */
//+ (instancetype)sharedHandler;

/**
 *  直接处理URL跳转
 */
- (BOOL)openUrl:(NSURL *)url inController:(UIViewController *)controller;

/**
 *  处理string型url的跳转
 */
- (BOOL)openStringUrl:(NSString *)url inController:(UIViewController *)controller;

/**
 *  对外部页面跳转URL请求进行处理
 *
 *  @param url 外部页面跳转请求
 *
 *  @return 是否可以跳转
 */
- (BOOL)openExternalUrl:(NSURL *)url inController:(UIViewController *)controller;

@end
