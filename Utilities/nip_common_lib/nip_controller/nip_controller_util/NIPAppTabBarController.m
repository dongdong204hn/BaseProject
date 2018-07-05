//
//  NIPAppTabBarController.m
//  NSIP
//
//  Created by Eric on 16/10/8.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPAppTabBarController.h"
#import "NIPBaseViewController.h"
#import "NIPSeparatorView.h"
#import "NIPUIFactory.h"
#import "NIPNavigationController.h"
#import "UIColor+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"
#import "nip_macros.h"


#define MIN_INDEX 0
#define MAX_INDEX 2

@interface NIPAppTabBarController () <UITabBarControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *tabIconImagesArray;
@property (nonatomic, strong) NSMutableArray *tabTitleLabelsArray;
@property (nonatomic, strong) UIView *tabBarBottomView;
@property (nonatomic, strong) UIView *tipView;

@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) NSArray *iconNames;
@property (nonatomic, strong) NSArray *tabBarNames;

@end

@implementation NIPAppTabBarController


#pragma mark - lifecycle

+ (NIPAppTabBarController *)currentTabBarController
{
    static NIPAppTabBarController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NIPAppTabBarController alloc] init];
        sharedInstance.delegate = sharedInstance;
    });
    return sharedInstance;
}

+ (instancetype)tabBarControllerWithRootControllers:(NSArray *)controllers andIconNames:(NSArray *)iconNames andTabBarNames:(NSArray *)tabBarNames{
    
    NIPAppTabBarController *instance = [self currentTabBarController];
    if (!instance.controllers) {
        instance.controllers = controllers;
        instance.iconNames = iconNames;
        instance.tabBarNames = tabBarNames;
        [instance myLoadView];
    }
    
    return instance;
}

//目的是推迟调用，取代viewDidLoad:，属性赋值后再调用
- (void)myLoadView {
    self.showNavigationAnimation = YES;
    [self initTabBar];
    [self setTabbarUpLineBackgroundColor];
    [self loadBaseUI];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusChanged)
                                                 name:@""//LOGIN_STATUS_CHANGED_NOTIFICATION
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadBaseUI
{
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)initTabBar {
    NSArray *defaultTabImageArray = self.iconNames;
    NSArray *tabTitleArray = self.tabBarNames;
    _tabIconImagesArray = [NSMutableArray array];
    _tabTitleLabelsArray = [NSMutableArray array];
    _tabBarBottomView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    _tabBarBottomView.backgroundColor = [UIColor whiteColor];
    NIPSeparatorView *topLine = [NIPSeparatorView separatorOfHeight:0.5];
    topLine.backgroundColor = [UIColor colorWithHexRGB:0xd9d9d9];
    
    [_tabBarBottomView addSubview:topLine];
    
    CGFloat tabBarItemWidth = SCREEN_WIDTH / (defaultTabImageArray.count / 2);
    
    NSInteger index = 0;
    for (; index < defaultTabImageArray.count / 2; index ++) {
        
        UIView *tabBarItemView = [[UIView alloc] initWithFrame:CGRectMake(index * tabBarItemWidth, 0, tabBarItemWidth, _tabBarBottomView.height)];
        UIImageView *iconImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:defaultTabImageArray[2 * index]]];
        iconImageV.contentMode = UIViewContentModeScaleAspectFit;
        [iconImageV setImage:[UIImage imageNamed:defaultTabImageArray[2 * index]]];
        [iconImageV setHighlightedImage:[UIImage imageNamed:defaultTabImageArray[2 * index + 1]]];
        
        UILabel *tabBarItemTitleLabel = [NIPUIFactory labelWithText:tabTitleArray[index] fontSize:11.5 andTextColor:[UIColor colorWithHexRGB:0x999999]];
        tabBarItemTitleLabel.width = tabBarItemView.width;
        tabBarItemTitleLabel.adjustsFontSizeToFitWidth = YES;
        tabBarItemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [tabBarItemView addSubview:iconImageV];
        [tabBarItemView addSubview:tabBarItemTitleLabel];
        
        iconImageV.top = 0;
        [iconImageV centerHorizontal];
        [tabBarItemTitleLabel centerHorizontal];
        tabBarItemTitleLabel.top = iconImageV.bottom + 2;
        tabBarItemView.height = tabBarItemTitleLabel.bottom;
        
        [_tabBarBottomView addSubview:tabBarItemView];
        tabBarItemView.centerY = _tabBarBottomView.height / 2;
        [_tabTitleLabelsArray addObject:tabBarItemTitleLabel];
        [_tabIconImagesArray addObject:iconImageV];
    }

    //下方两条语句前后顺序不可变
    [self.tabBar addSubview:_tabBarBottomView];
    self.viewControllers = self.controllers;
}


//- (void)reloadTabBarWithTabInfoArray:(NSArray *)array
//{
//    if (array.count != 3) {
//        //如果后台不返回tab图标配置信息，则恢复默认tab图标大小
//        for (int i = 0; i < 3; i++) {
//            
//            UILabel *tabLabel = _tabLabelArray[i];
//            UIImageView *tabImgV = _tabImageArray[i];
//            tabImgV.bounds = CGRectMake(0, 0, 41, 27);
//            tabImgV.bottom = tabLabel.top - 2;
//        }
//        return;
//    }
//    dispatch_group_t downLoadGroup = dispatch_group_create();
//    for (int i = 0; i < 3; i ++) {
//        CFTabInfo *tabInfo = array[i];
//        dispatch_group_enter(downLoadGroup);
//        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:tabInfo.unfocusPic] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            
//        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            if (image && finished) {
//                [[SDImageCache sharedImageCache] storeImage:image forKey:tabInfo.unfocusPic];
//                dispatch_group_leave(downLoadGroup);
//            }
//        }];
//        dispatch_group_enter(downLoadGroup);
//        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:tabInfo.focusPic] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
//            
//        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            if (image && finished) {
//                [[SDImageCache sharedImageCache] storeImage:image forKey:tabInfo.focusPic];
//                dispatch_group_leave(downLoadGroup);
//            }
//        }];
//        
//    }
//    dispatch_group_notify(downLoadGroup, dispatch_get_main_queue(), ^{
//        for (int i = 0; i < 3; i++) {
//            
//            CFTabInfo *tabInfo = array[i];
//            UILabel *tabLabel = _tabLabelArray[i];
//            tabLabel.text = tabInfo.title;
//            UIImageView *tabImgV = _tabImageArray[i];
//            tabImgV.bounds = CGRectMake(0, 0, 48, 35);
//            tabImgV.bottom = tabLabel.top - 2;
//            UIImage *focusImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:tabInfo.focusPic];
//            UIImage *unfocusImg = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:tabInfo.unfocusPic];
//            if (focusImg && unfocusImg) {
//                tabImgV.highlightedImage = focusImg;
//                tabImgV.image = unfocusImg;
//            }
//        }
//    });
//}

- (void)setTabbarUpLineBackgroundColor
{
    UIImage *img = [[UIImage alloc] init];
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:img];
    [self.tabBar setShadowImage:img];
}


#pragma mark - action code

- (void)loginStatusChanged {
    
}

- (void)popToRootWithTabIndex:(NSInteger)index
{
    if (index < MIN_INDEX || index > MAX_INDEX) {
        return;
    }
    UINavigationController *navController;
    navController = [self.controllers objectAtIndex:index];
    
    if ([self tabBarController:self shouldSelectViewController:navController]) {
        self.selectedIndex = index;
        [[navController topViewController] dismissViewControllerAnimated:NO
                                                              completion:^{
                                                                  [navController popToRootViewControllerAnimated:NO];
                                                              }];
    }
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSInteger highlightedIndex = [self.viewControllers indexOfObject:viewController];
    [self updateHighlightedIndex:highlightedIndex];
    return YES;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if ([self updateHighlightedIndex:selectedIndex]) {
        super.selectedIndex = selectedIndex;
    }
}

- (BOOL)updateHighlightedIndex:(NSInteger)hightlightedIndex
{
    if (hightlightedIndex != self.selectedIndex) {
        UIImageView *iconImageView;
        UILabel *tabBarItemTitleLabel;
        if (NOT_EMPTY_ARRAY(_tabIconImagesArray) && NOT_EMPTY_ARRAY(_tabTitleLabelsArray)) {
            if (self.selectedIndex != NSNotFound) {
                iconImageView = [_tabIconImagesArray objectAtIndex:self.selectedIndex];
                tabBarItemTitleLabel = [_tabTitleLabelsArray objectAtIndex:self.selectedIndex];
                iconImageView.highlighted = NO;
                tabBarItemTitleLabel.textColor = [UIColor colorWithRed:111.0/255 green:111.0/255 blue:111.0/255 alpha:1.0];
            }
            
            iconImageView = [_tabIconImagesArray objectAtIndex:hightlightedIndex];
            tabBarItemTitleLabel = [_tabTitleLabelsArray objectAtIndex:hightlightedIndex];
            iconImageView.highlighted = YES;
            tabBarItemTitleLabel.textColor = [UIColor colorWithRed:18.0/255 green:61.0/255 blue:156.0/255 alpha:1.0];
            return  YES;
        }
    }
    return NO;
}

#pragma mark - Setters && Getters

- (UINavigationController *)currentNavigationController {
    UINavigationController *navController;
    navController = [self.controllers objectAtIndex:self.selectedIndex];
    return navController;
}



@end
