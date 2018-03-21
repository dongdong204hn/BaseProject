//
//  NIPUrlControllerRouter.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPUrlControllerProtocol.h"

/**
 *  NIPUrlControllerRouter是一个依据url跳转controller的控制器
 *  可以通过url提取路径、参数，并使用push&present的手段来进行自动的页面跳转
 */
@interface NIPUrlControllerRouter : NSObject

/**
 这个属性必须被设置，NIPUrlControllerRouter的默认行为都是基于rootViewController
 **/
@property(nonatomic,weak) UIViewController *rootViewController;

//这个方法可以被覆盖，对于某些url客户程序可以自行处理，某些url交由基类处理
- (void)handleUrlRequest:(NSURL*)url inController:(UIViewController*)controller;

//必须被覆盖，创建每个字符串名字对应的controller
- (UIViewController*)controllerOfPageId:(NSString*)pageId;
@end


@interface NIPUrlControllerRouter(util) //工具方法
/*
 基于rootViewController的最顶层的controller，即，尚未present其他controller
 */
- (UIViewController*)viewControllerForPresenting;

/*
 判断一个controller是否最顶层controller，这样的controller才可以present其他controller
 */
- (BOOL)isViewControllerTop:(UIViewController*)controller;

/*
 dismiss掉所有的controller
 慎用：可能会破话你的业务逻辑
 */
- (void)dismissAllPresentedController;


- (NSArray*)parsePathComponentsFromURL:(NSURL*)url;

- (NSDictionary*)parseParamFromURL:(NSURL*)url;
@end
