//
//  NIPWebViewController.h
//  NSIP
//
//  Created by Eric on 16/10/14.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPMyBaseViewController.h"

@interface NIPWebViewController : NIPMyBaseViewController


@property (nonatomic, strong) NSString *startupURLString;
@property (nonatomic, strong) NSURLRequest *startupRequest;

@property (nonatomic,strong) NSString *jsCallback; //点击导航栏时的回调

@property (nonatomic, assign) BOOL hideToolBar;

/**
 *  设置webview加载菊花的显示、隐藏和颜色
 */
- (void)showLoadingActivityView;
- (void)hideLoadingActivityView;
- (void)setLoadingActivityViewColor:(UIColor *)color;

/**
 *  设定左上角返回按钮是否生效
 *
 *  @param enable 如果为true，是默认行为，可以回到wap的上一个页面，如果为false，则直接关闭webview
 */
- (void)setBackButtonEnable:(BOOL)enable;

- (void)setNavigationRightBtnWithType:(NSInteger)type andTitle:(NSString *)title;


@end
