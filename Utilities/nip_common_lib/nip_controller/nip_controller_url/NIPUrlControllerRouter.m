//
//  NIPUrlControllerRouter.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPUrlControllerRouter.h"

@implementation NIPUrlControllerRouter

- (void)handleUrlRequest:(NSURL*)url inController:(UIViewController*)sourceController {
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:
                                      [self parsePathComponentsFromURL:url]];
    if (pathComponents.count==0) {
        return;
    }
    NSDictionary *param = [self parseParamFromURL:url];

    
    UIViewController *tempSourceController = sourceController;
    sourceController = self.rootViewController;
    if (tempSourceController&&[tempSourceController respondsToSelector:@selector(urlControllerCanHanlePageRedirect:)]) {
         id<NIPUrlControllerProtocol> controller = (id<NIPUrlControllerProtocol>)tempSourceController;
        if ([controller urlControllerCanHanlePageRedirect:pathComponents[0]]) {
            sourceController = tempSourceController;
        }
    }
    
    
    while (sourceController&&pathComponents.count>0) {
        id<NIPUrlControllerProtocol> controller = (id<NIPUrlControllerProtocol>)sourceController;
        if ([controller respondsToSelector:@selector(urlControllerCanHanlePageRedirect:)]
            &&[controller urlControllerCanHanlePageRedirect:pathComponents[0]]) {
            sourceController = [controller urlControllerHandlePageRedirect:pathComponents[0]
                                                             withParameter:param
                                                                  animated:pathComponents.count==1];
        } else {
            if ([self isViewControllerTop:sourceController]) {
                sourceController = [self autoHandlePageRedirect:pathComponents[0]
                                                      withParam:param
                                                   inController:sourceController
                                                       animated:pathComponents.count==1];
            }
        }
        [pathComponents removeObjectAtIndex:0];
    }
}

- (UIViewController*)autoHandlePageRedirect:(NSString*)pageId withParam:(NSDictionary*)param
                               inController:(UIViewController*)sourceController animated:(BOOL)animated {
    
    UIViewController *controller = [self controllerOfPageId:pageId];
    if (!controller) {
        return nil;
    }
    
    if ([controller respondsToSelector:@selector(urlControllerPrepareWithParameter:)]) {
        BOOL prepared = [(id<NIPUrlControllerProtocol>)controller urlControllerPrepareWithParameter:param];
        if (!prepared) {
            return nil;
        }
    }
    
    if ([controller respondsToSelector:@selector(urlControllerShouldBePresented)]
        &&[(id<NIPUrlControllerProtocol>)controller urlControllerShouldBePresented]) {
        [[self viewControllerForPresenting] presentViewController:controller animated:NO completion:nil];
    } else {    
        UINavigationController *naviController = sourceController.navigationController;
        if ([sourceController isKindOfClass:[UINavigationController class]]) {
            naviController = (UINavigationController*)sourceController;
        }
        if (naviController) {
            [naviController pushViewController:controller animated:animated];
        } else {
            return nil;
        }
    }
    return controller;
}

- (UIViewController*)controllerOfPageId:(NSString*)pageId {
    return nil;
}

@end


@implementation NIPUrlControllerRouter(util) //工具方法

- (UIViewController*)viewControllerForPresenting  {
    UIViewController *controller = self.rootViewController;
    while (controller.parentViewController) {
        controller = controller.parentViewController;
    }
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    return controller;
}

- (BOOL)isViewControllerTop:(UIViewController*)controller {
    UIViewController *topController = [self viewControllerForPresenting];
    while (controller&&controller!=topController) {
        controller = controller.parentViewController;
    }
    return (controller!=nil);
}

- (void)dismissAllPresentedController {
    NSMutableArray *presentStack = [NSMutableArray array];
    UIViewController *controller = self.rootViewController;
    while (controller.presentedViewController) {
        [presentStack addObject:controller];
        controller = controller.presentedViewController;
    }
    [presentStack enumerateObjectsWithOptions:NSEnumerationReverse
                                   usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       [(UIViewController*)obj dismissViewControllerAnimated:NO completion:nil];
                                   }];
}

//private methods
- (NSArray*)parsePathComponentsFromURL:(NSURL*)url {
    NSArray *array = [url.resourceSpecifier componentsSeparatedByString:@"?"];
    if ([array count]>0) {
        NSString *pathString = [array objectAtIndex:0];
        pathString = [pathString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]];
        return [pathString componentsSeparatedByString:@"/"];
    }
    return array;
}

- (NSDictionary*)parseParamFromURL:(NSURL*)url {
    NSString *paramString = nil;
    NSArray *array = [url.resourceSpecifier componentsSeparatedByString:@"?"];
    if ([array count]>1) {
        paramString = [array objectAtIndex:1];
    }
    
    NSArray *keyValueArray = [paramString componentsSeparatedByString:@"&"];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    for (NSString *pair in keyValueArray) {
        NSArray *pairArray = [pair componentsSeparatedByString:@"="];
        if ([pairArray count]==2) {
            NSString *value = [pairArray objectAtIndex:1];
            
            value = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                          (__bridge CFStringRef)value,
                                                                                                          CFSTR(""),
                                                                                                          kCFStringEncodingUTF8);
            [param setObject:value forKey:[pairArray objectAtIndex:0]];
        }
    }
    return param;
}

@end
