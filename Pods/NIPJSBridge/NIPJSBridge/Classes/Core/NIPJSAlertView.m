//
//  NIPJSAlertView.m
//  Pods
//
//  Created by Eric on 2017/6/20.
//
//

#import "NIPJSAlertView.h"


@interface NIPJSAlertView ()

@property (nonatomic, strong) UIAlertController *alertView;

@end

@implementation NIPJSAlertView


+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
    [self simpleAlertWithTitle:title message:message onDismiss:nil];
}

+ (void)simpleAlertWithTitle:(NSString *)title
                     message:(NSString *)message
                   onDismiss:(NIPAlerViewDidDismissBlock)dismissBlock {
    NIPJSAlertView *alert = [[NIPJSAlertView alloc] initWithTitle:title
                                                          message:message
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
    alert.onDismissBlock = dismissBlock;
    [alert show];
}

+ (void)warmAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                 onDismiss:(NIPAlerViewDidDismissBlock)dismissBlock {
    NIPJSAlertView *alert = [[NIPJSAlertView alloc] initWithTitle:title
                                                          message:message
                                                cancelButtonTitle:@"我知道了"
                                                otherButtonTitles:nil];
    alert.onDismissBlock = dismissBlock;
    [alert show];
}

+ (void)questionAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                     onDismiss:(NIPAlerViewDidDismissBlock)dismissBlock {
    NIPJSAlertView *alert = [[NIPJSAlertView alloc] initWithTitle:title
                                                          message:message
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定",nil];
    alert.onDismissBlock = dismissBlock;
    [alert show];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    self = [super init];
    if (self) {
        self.alertView = [UIAlertController alertControllerWithTitle:title
                                                             message:message
                                                      preferredStyle:UIAlertControllerStyleAlert];
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
    }
    return self;
}

- (void)show {
    UIViewController *topViewController = [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    if (![topViewController isKindOfClass:[UIAlertController class]]) { //避免alertcontroller弹出多次
        [topViewController presentViewController:self.alertView animated:YES completion:nil];
    }
}



- (void)addActionWithTitle:(NSString*)title
                     style:(UIAlertActionStyle)actionStyle
            andButtonIndex:(NSInteger)buttonIndex {
    UIAlertAction* action = [UIAlertAction actionWithTitle:title
                                                     style:actionStyle
                                                   handler:^(UIAlertAction * action) {
                                                       if (self.onDismissBlock) {
                                                           self.onDismissBlock(buttonIndex);
                                                       }
                                                       self.alertView = nil;
                                                   }];
    [self.alertView addAction:action];
}

#pragma mark - 当前的顶层viewcontroller

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
