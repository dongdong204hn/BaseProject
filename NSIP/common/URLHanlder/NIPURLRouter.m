//
//  NIPURLRouter.m
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPURLRouter.h"
#import "NSIPPageURLsDataset.h"
#import <JLRoutes/JLRoutes.h>
#import <objc/runtime.h>
#import "NIPAppTabBarController.h"
#import "NIPUIFactoryChild.h"
#import "NIPBaseViewController.h"
#import "UIViewController+TopMostViewController.h"
#import "NIPImageFactory.h"
#import "nip_macros.h"
#import "NSString+NIPBasicAdditions.h"
#import "NSURL+NIPBasicAdditions.h"
#import "NIPNavigationController.h"



#define NT_JUMPURL_BASECONTROLLER_KEY @"JUMP_BASE_VIEW_CONTROLLER_KEY"
#define NT_JUMPURL_IS_FROM_ROOT_KEY @"FROM_ROOT"
#define NT_JUMPURL_FROM_ROOT_TAB_INDEX @"tabIndex"
#define NT_JUMPURL_NEED_LOGIN @"NEED_LOGIN"

@implementation NIPURLRouter


+ (instancetype)sharedRouter {
    static NIPURLRouter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NIPURLRouter alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registRouters];
    }
    return self;
}

- (void)registRouters {
    [self registTabRouter];
    [self registCommonRouter];
}

- (void)registTabRouter {
    NSArray *tabURLs = [NSIPPageURLsDataset tabURLs];
    WEAK_SELF(weakSelf)
    for (int i = 0; i < tabURLs.count; i++) {
        NSString *tabUrl = [tabURLs objectAtIndex:i];
        [[JLRoutes globalRoutes]  addRoute:[self getRoutes:tabUrl]
                                   handler:^BOOL(NSDictionary *parameters) {
                                       [weakSelf gotoTabPage:i params:parameters];
                                       return YES;
                                   }];
    }
}

- (void)registCommonRouter {
    NSArray *commonURLs = [NSIPPageURLsDataset commonURLs];
    WEAK_SELF(weakSelf);
    for (NSArray *urlInfos in commonURLs) {
        if (urlInfos.count >= 4) {
            NSString *urlStr = [urlInfos objectAtIndex:0];
            __weak NSString *className = [urlInfos objectAtIndex:1];
            BOOL isNeedLogin = [[urlInfos objectAtIndex:2] boolValue];
            NSInteger tabIndex = [[urlInfos objectAtIndex:3] integerValue];
            
            [[JLRoutes globalRoutes]  addRoute:[self getRoutes:urlStr]
                                       handler:^BOOL(NSDictionary *parameters) {
                                           [weakSelf gotoPageWithParams:parameters controller:className isNeedLogin:isNeedLogin tabIndex:tabIndex];
                                           
                                           return YES;
                                       }];
        }
        
    }
}


#pragma mark - 添加"/"

- (NSString *)getRoutes:(NSString *)path
{
    return [NSString stringWithFormat:@"/%@", path];
}


#pragma mark - 页面属性设置

- (void)setProperties:(NSDictionary *)parameters forViewController:(id)viewController {
    const char *className = object_getClassName(viewController);
    id classOfViewController = objc_getClass(className);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(classOfViewController, &outCount);
    for (NSString *parm in parameters) {
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
            if ([propName isEqualToString:parm]) {
                const char *p_type_str = property_getAttributes(property);
                NSString *attrTypeStrS = [NSString stringWithUTF8String:p_type_str];
                NSArray *attrArray = [attrTypeStrS componentsSeparatedByString:@","];
                NSString *attrTypeStr = attrArray[0];
                const char *p_type = [[attrTypeStr substringFromIndex:1] UTF8String];
                if (!strcmp(p_type, @encode(BOOL))) {
                    NSNumber *number = [NSNumber numberWithBool:[((NSString *)parameters[propName])boolValue]];
                    [viewController setValue:number forKey:propName];
                }
                else if (!strcmp(p_type, @encode(NSInteger)) || !strcmp(p_type, @encode(NSUInteger))) {
                    NSNumber *number = [NSNumber numberWithInteger:[((NSString *)parameters[propName])integerValue]];
                    [viewController setValue:number forKey:propName];
                }
                else if ([attrTypeStrS containsSubstring:@"NSString"]) {
                    [viewController setValue:parameters[propName] forKey:propName];
                }
                else if (!strcmp(p_type, @encode(double))) {
                    NSNumber *number = [NSNumber numberWithDouble:[((NSString *)parameters[propName])doubleValue]];
                    [viewController setValue:number forKey:propName];
                }
                else if (!strcmp(p_type, @encode(float))) {
                    NSNumber *number = [NSNumber numberWithFloat:[((NSString *)parameters[propName])floatValue]];
                    [viewController setValue:number forKey:propName];
                }
                else if ([attrTypeStrS containsSubstring:@"NSNumber"]) {
                    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
                    numFormat.numberStyle = NSNumberFormatterDecimalStyle;
                    NSNumber *number = [numFormat numberFromString:(NSString *)parameters[propName]];
                    [viewController setValue:number forKey:propName];
                }
                else { //目前只能处理BOOL,NSInteger,NSUInteger,CGFloat,NSString,NSNumber类型，其他类型不能处理
                    NSAssert(0, @"not support");
                }
            }
        }
    }
}


#pragma mark - 打开链接

- (BOOL)openURL:(NSURL *)url baseViewController:(UIViewController *)baseViewController
{
    if (!url) {
        return NO;
    }
    BOOL jumpFromRoot = false; //是否基于tab页的root页进行跳转
    if (!baseViewController) {
        baseViewController = [UIViewController topmostViewController]; //当前应用最上层的viewController,一般是用户当前进行操作的ViewController
        jumpFromRoot = true;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:url.parametersDictionary];
    [parameters setObject:baseViewController forKey:NT_JUMPURL_BASECONTROLLER_KEY];
    [parameters setObject:@(jumpFromRoot) forKey:NT_JUMPURL_IS_FROM_ROOT_KEY];
    return [JLRoutes routeURL:url
               withParameters:parameters]; //将最上层的viewController和是否基于tab页跳转作为参数传递进处理跳转逻辑的block，供跳转使用
}


#pragma mark - 页面跳转部分

/**
 *  tab页之间的切换
 *
 *  @param pageIndex  将要切换至的tab页
 *  @param parameters 需要设置的参数
 */
- (void)gotoTabPage:(NSInteger)pageIndex params:(NSDictionary *)parameters {
    [[NIPAppTabBarController currentTabBarController] popToRootWithTabIndex:pageIndex];
    UIViewController *baseViewController = parameters[NT_JUMPURL_BASECONTROLLER_KEY];
    [self popToRootNavController:baseViewController];
}

/**
 *  跳转到具体页面
 *
 *  @param parameters  传递参数
 *  @param className   跳转至的页面
 *  @param isNeedLogin 是否需要登录
 *  @param tabIndex    所属tab页
 */
- (void)gotoPageWithParams:(NSDictionary *)parameters
                controller:(NSString *)className
               isNeedLogin:(BOOL)isNeedLogin
                  tabIndex:(NSInteger)tabIndex
{
    Class cls = NSClassFromString(className);
    if (cls) {
        id controller = [[cls alloc] init];
        [self pushController:controller params:parameters isNeedLogin:isNeedLogin tabIndex:tabIndex];
    }
#ifdef TEST_VERSION
    else {
        
        @throw [NSException exceptionWithName:@"CFURLRoute"
                                       reason:[NSString stringWithFormat:@"%@ not exsit", className]
                                     userInfo:nil];
    }
#endif
}

- (void)pushController:(UIViewController *)controller
                params:(NSDictionary *)parameters
           isNeedLogin:(BOOL)isNeedLogin
              tabIndex:(NSInteger)tabIndex
{
    [self setProperties:parameters forViewController:controller];
    [parameters setValue:[NSNumber numberWithInteger:tabIndex] forKey:NT_JUMPURL_FROM_ROOT_TAB_INDEX];
    [parameters setValue:[NSNumber numberWithBool:isNeedLogin] forKey:NT_JUMPURL_NEED_LOGIN];
    [self pushViewController:controller withParameters:parameters];
}


- (void)pushViewController:(UIViewController *)controller withParameters:(NSDictionary *)parameters
{
    BOOL needLogin = [parameters[NT_JUMPURL_NEED_LOGIN] boolValue];
    BOOL jumpFromRoot = [parameters[NT_JUMPURL_IS_FROM_ROOT_KEY] boolValue];
    UIViewController *baseViewController = parameters[NT_JUMPURL_BASECONTROLLER_KEY];
    
    if (jumpFromRoot) {
        int tabIndex = [parameters[NT_JUMPURL_FROM_ROOT_TAB_INDEX] intValue];
        [[NIPAppTabBarController currentTabBarController] popToRootWithTabIndex:tabIndex];
        [self popToRootNavController:baseViewController];
        [self pushViewController:[NIPAppTabBarController currentTabBarController].currentNavigationController toController:controller jumpFromRoot:jumpFromRoot needLogin:needLogin];
    }
    else {
        [self pushViewController:baseViewController toController:controller jumpFromRoot:jumpFromRoot needLogin:needLogin];
    }
}

- (void)pushViewController:(UIViewController *)fromController
              toController:(UIViewController *)toController
              jumpFromRoot:(BOOL)jumpFromRoot
                 needLogin:(BOOL)needLogin
{
    if (needLogin) {
        
//        if (![NIPLoginSession sharedSession].hasLoginURS) { //跳转需要登录的只要urs登录成功即可，没必要必须等从后台拿到用户数据时才算，这样可以解决从外部唤起应用时还没有拿到cfuser数据，就弹出登录框
//            [self pushLoginController:fromController toController:toController];
//        }
//        //        else if ([GesturePasswordView existPassword] && jumpFromRoot == YES) {
//        //            [self pushGestureController:fromController toController:toController];
//        //        }
//        else {
//            [self pushViewController:toController withBaseController:fromController];
//        }
    }
    else {
        [self pushViewController:toController withBaseController:fromController];
    }
}

- (void)pushViewController:(UIViewController *)viewController withBaseController:(UIViewController *)baseViewController
{
    if ([baseViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)baseViewController pushViewController:viewController animated:YES];
    }
    else if (baseViewController.navigationController) {
        [baseViewController.navigationController pushViewController:viewController animated:YES];
    }
    else { //如果既不是navController也不是navController push后的页面，则用present方式打开
        UINavigationController *navController = [[NIPNavigationController alloc] initWithRootViewController:viewController];
        [NIPUIFactory setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:navController.navigationBar];
        if ([viewController isKindOfClass:[NIPBaseViewController class]]) {
            ((NIPBaseViewController *)viewController).naviLeftView = [NIPUIFactoryChild naviBackButtonWithTarget:viewController selector:@selector(baseBackButtonPressed:)]; //baseBackButtonPressed返回按钮的行为在基类中定义
        }
        [baseViewController presentViewController:navController animated:YES completion:nil];
    }
}


#pragma mark - 跳转响应
/**
 *  将指定controller跳到所在的navicontroller的root
 *
 *  @param baseViewController 指定的controller
 */
- (void)popToRootNavController:(UIViewController *)baseViewController
{
    UIViewController *presentingController = baseViewController.presentingViewController;
    if (presentingController) { //baseViewController 有可能是present出的窗口，比如支付弹窗，需要dismiss掉
        [presentingController dismissViewControllerAnimated:NO completion:^{
        }];
    }
    else {
        if ([baseViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)baseViewController popToRootViewControllerAnimated:NO];
        }
        else if (baseViewController.navigationController) {
            [baseViewController.navigationController popToRootViewControllerAnimated:NO];
        }
    }
}


@end
