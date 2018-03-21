//
//  NIPMyBaseViewController.m
//  NSIP
//
//  Created by 赵松 on 16/12/7.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPMyBaseViewController.h"
#import "NIPUIFactoryChild.h"
#import "NIPImageFactory.h"
#import "AppDelegate.h"
#import "UIViewController+TopMostViewController.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "UIImage+NIPBasicAdditions.h"

@interface NIPMyBaseViewController ()

@end

@implementation NIPMyBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBlueNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 切换导航栏视图

- (void)setWhiteNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        titleLabel.textColor = [UIColor blackColor];
    }
    if (self.navigationController) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        if (self.navigationController.viewControllers.count > 1) {
            self.naviLeftView = [NIPUIFactoryChild naviBlackBackButtonWithTarget:self selector:@selector(baseBackButtonPressed:)];
        }
    }
}

- (void)setBlueNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        titleLabel.textColor = [UIColor whiteColor];
    }
    if (self.navigationController) {
        [NIPUIFactoryChild setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:self.navigationController.navigationBar];
        if (self.navigationController.viewControllers.count > 1) {
            self.naviLeftView = [NIPUIFactoryChild naviBackButtonWithTarget:self selector:@selector(baseBackButtonPressed:)];
        }
    }
}

- (void)setTranspaNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        titleLabel.textColor = [UIColor blackColor];
    }
    if (self.navigationController) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake([UIDevice screenWidth], 50)] forBarMetrics:UIBarMetricsCompact];
        if (self.navigationController.viewControllers.count > 1) {
            self.naviLeftView = [NIPUIFactoryChild naviBlackBackButtonWithTarget:self selector:@selector(baseBackButtonPressed:)];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
