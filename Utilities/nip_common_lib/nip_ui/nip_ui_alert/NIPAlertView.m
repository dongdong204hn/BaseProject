//
//  NIPAlertView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "NIPAlertView.h"


@interface NIPAlertView()

@property (nonatomic,strong) id alertObject;

@end


@implementation NIPAlertView


@synthesize onDismissBlock=_onDismissBlock;

+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
    [self simpleAlertWithTitle:title message:message onDismiss:nil];
}

+ (void)simpleAlertWithTitle:(NSString *)title
                     message:(NSString *)message
                   onDismiss:(AlertDismissBlock)dismissBlock {
    NIPAlertView *alert = [[NIPAlertView alloc] initWithTitle:title
                                                    message:message
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    alert.onDismissBlock = dismissBlock;
    [alert show];
}

+ (void)warmAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                 onDismiss:(AlertDismissBlock)dismissBlock {
    NIPAlertView *alert = [[NIPAlertView alloc] initWithTitle:title
                                                    message:message
                                          cancelButtonTitle:@"我知道了"
                                          otherButtonTitles:nil];
    alert.onDismissBlock = dismissBlock;
    [alert show];
}

+ (void)questionAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                     onDismiss:(AlertDismissBlock)dismissBlock {
    NIPAlertView *alert = [[NIPAlertView alloc] initWithTitle:title
                                                    message:message
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    alert.onDismissBlock = dismissBlock;
    [alert show];
    
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id<UIAlertViewDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    @throw [NSException exceptionWithName:@"初始化错误" reason:@"为了方便使用UIAlertController，请使用initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...进行初始化" userInfo:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super init];
    if (self) {
        if ([UIAlertController class]) { //ios8 or later
            self.alertObject = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            if (cancelButtonTitle) {
                [self addActionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel andButtonIndex:0];
            }
            if (otherButtonTitles) {
                [self addActionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault andButtonIndex:1];
                va_list otherButtonTitleArgList;
                va_start(otherButtonTitleArgList, otherButtonTitles);
                NSString *buttonTitle = nil;
                int i = 2;
                while ((buttonTitle = va_arg(otherButtonTitleArgList, NSString*))) {
                    [self addActionWithTitle:buttonTitle style:UIAlertActionStyleDefault andButtonIndex:i++];
                }
                va_end(otherButtonTitleArgList);
            }
        } else{
            self.alertObject = [[UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:(id<UIAlertViewDelegate>)self
                                                cancelButtonTitle:cancelButtonTitle
                                                otherButtonTitles:otherButtonTitles,nil];
            [self performSelector:@selector(timeout) withObject:nil afterDelay:600];//这里是防止arc 自动把本类释放，delegate回调会成nil，造成崩溃
            if  (otherButtonTitles) {
                va_list otherButtonTitleArgList;
                va_start(otherButtonTitleArgList, otherButtonTitles);
                NSString *butotnTitle = va_arg(otherButtonTitleArgList, typeof(NSString*));
                while (butotnTitle!=nil) {
                    [self.alertObject addButtonWithTitle:butotnTitle];
                    butotnTitle = va_arg(otherButtonTitleArgList, typeof(NSString*));
                }
                va_end(otherButtonTitleArgList);
            }
        }
    }
    
    return self;
}

- (void)timeout{
    if (![UIAlertController class]) { //alertview需要特殊处理
        UIAlertView *alertView = (UIAlertView *)self.alertObject;
        alertView.delegate = nil;
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
        alertView = nil;
        [[self class]  cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)addActionWithTitle:(NSString*)title style:(UIAlertActionStyle)actionStyle andButtonIndex:(NSInteger)buttonIndex{
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:title
                                                            style:actionStyle
                                                          handler:^(UIAlertAction * action) {
                                                              if (self.onDismissBlock) {
                                                                  self.onDismissBlock(buttonIndex);
                                                              }
                                                              self.alertObject = nil;
                                                          }];
    [self.alertObject addAction:defaultAction];
}

- (void)show {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    if ([UIAlertController class]) { //ios8 or later
        UIViewController *topController = [self  topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        if (![topController isKindOfClass:[UIAlertController class]]) { //避免alertcontroller弹出多次
            [topController presentViewController:self.alertObject animated:YES completion:nil];
        }
    }else{
        [self.alertObject performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if(![UIAlertController class]){
        UIAlertView *alertView = (UIAlertView*)self.alertObject;
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:NO];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.onDismissBlock) {
        self.onDismissBlock(buttonIndex);
    }
    [self timeout];//正常关闭的也需要清空，否则会造成该类无法释放
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


@end
