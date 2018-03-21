//
//  NIPURLHandler.h
//  NSIP
//
//  Created by 赵松 on 17/3/16.
//  Copyright © 2017年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPURLHandler : NSObject

/**
 *  获取NIPURLHandler单例
 */
+ (instancetype)sharedHandler;

#pragma mark - 具体项目在分类覆盖以下方法
///**
// *  直接处理URL跳转
// */
//- (BOOL)openUrl:(NSURL *)url inController:(UIViewController *)controller;
//
///**
// *  处理string型url的跳转
// */
//- (BOOL)openStringUrl:(NSString *)url inController:(UIViewController *)controller;
//
///**
// *  对外部页面跳转URL请求进行处理
// *
// *  @param url 外部页面跳转请求
// *
// *  @return 是否可以跳转
// */
//- (BOOL)openExternalUrl:(NSURL *)url inController:(UIViewController *)controller;

@end
