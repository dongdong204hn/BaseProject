//
//  NIPSlideViewController.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseViewController.h"
#import "nip_ui_geometry.h"

@class NIPSlideViewController;


@protocol ZBSlideViewControllerDelegate <NSObject>
- (UIViewController*)leftControllerOfSideViewController:(NIPSlideViewController*)slideController;
- (UIViewController*)rightControllerOfSideViewController:(NIPSlideViewController*)slideController;
@end

/**
 *  支持侧滑的root controller
 */
@interface NIPSlideViewController : NIPBaseViewController
@property(nonatomic,strong) UIViewController *mainViewController;
@property(nonatomic,readonly) BOOL isShowingMainViewController;
@property(nonatomic) CGFloat marginSpace;

@property(nonatomic,weak) id<ZBSlideViewControllerDelegate> delegate;

- (void)showRightViewController;
- (void)showMainViewController;
- (void)showLeftViewController;

@end
