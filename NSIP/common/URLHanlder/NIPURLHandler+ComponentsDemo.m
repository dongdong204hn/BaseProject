//
//  NIPURLHandler.m
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPURLHandler+ComponentsDemo.h"
#import "NIPCommonUtil.h"
#import "NIPURLRouter.h"
#import "NIPWebViewController.h"
#import "NIPWebNavigationController.h"
#import "NIPUIFactoryChild.h"
#import "UIViewController+TopMostViewController.h"
#import "NIPImageFactory.h"
#import "NSURL+NIPBasicAdditions.h"

@implementation NIPURLHandler (ComponentsDemo)

//+ (instancetype)sharedHandler {
//    static NIPURLHandler *sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[NIPURLHandler alloc] init];
//    });
//    return sharedInstance;
//}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL)openStringUrl:(NSString *)url inController:(UIViewController *)controller
{
    // 假如输入字符串包含中文字符需要进行UTF8编码，但是假如已经进行过编码，二次编码也会带来问题，所以先移除再编码可以解决这个问题。
    NSString *stingByReplacedUTF8Encoding = [url stringByRemovingPercentEncoding];
    NSString *URLStringEncodedByUTF8 = [stingByReplacedUTF8Encoding stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [self openUrl:[NSURL URLWithString:URLStringEncodedByUTF8] inController:controller];
}

- (BOOL)openExternalUrl:(NSURL *)url inController:(UIViewController *)controrller
{
    return [self openUrl:url inController:controrller];
}

- (BOOL)openUrl:(NSURL *)url inController:(UIViewController *)controller
{
    NSString *scheme = [[url scheme] lowercaseString];
    NSString *URLStringConvertedFromApplink = [NIPCommonUtil convertlinkUrl:url].absoluteString;
    if ([scheme hasPrefix:NSIP_PREFIX] ||
        [URLStringConvertedFromApplink hasPrefix:NSIP_PREFIX]) {
        [[NIPURLRouter sharedRouter] openURL:[NIPCommonUtil convertlinkUrl:url] baseViewController:controller];
        return YES;
    }
    if ([scheme hasPrefix:@"http"])
    {
        
        if (!controller) {
            controller = [UIViewController topmostViewController]; //当前应用最上层的viewController,一般是用户当前进行操作的ViewController
            
        }
        NIPWebViewController *webViewController = [[NIPWebViewController alloc] init];
//        url = [NIPCommonUtil redirectUrl:url];
        webViewController.startupURLString = [url absoluteString];
        NSDictionary *params = [url parametersDictionary];
        if (params[@"hideToolBar"]) {
            webViewController.hideToolBar = params[@"hideToolBar"];
        }
        if ([controller isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)controller pushViewController:webViewController animated:YES];
        }
        else if (controller.navigationController) {
            [controller.navigationController pushViewController:webViewController animated:YES];
        }
        else { //如果既不是navController也不是navController push后的页面，则用present方式打开
            NIPWebNavigationController *navController = [[NIPWebNavigationController alloc] initWithRootViewController:webViewController];
            [NIPUIFactory setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:navController.navigationBar];
            
            ((NIPBaseViewController *)webViewController).naviLeftView = [NIPUIFactoryChild naviBackButtonWithTarget:webViewController selector:@selector(baseBackButtonPressed:)]; //baseBackButtonPressed返回按钮的行为在基类中定义
            
            [controller presentViewController:navController animated:YES completion:nil];
        }
        return YES;
    }
    
//    BOOL handled = [TencentOAuth HandleOpenURL:url] || [NTShareKit handleOpenURL:url];
//    if (!handled){
//        return [[UIApplication sharedApplication] openURL:url];
//    }
//    return handled;
    return YES;
}




@end
