//
//  NIPContainerViewController.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseViewController.h"

@protocol NTContainerViewControllerDelegate;

extern NSString *const UITransitionContextFromViewControllerKey_BackCompatible; //替代UITransitionContextFromViewControllerKey，兼容ios6，5
extern NSString *const UITransitionContextToViewControllerKey_BackCompatible; //替代UITransitionContextToViewControllerKey，兼容ios6，5

/**
 *  NIPContainerViewController是一个组合controller，使用在一些需要将多个controller组合在一起，而系统提供的组合controller(UINavigationController,UITabViewController)又不能适用的场合
 *  通过containerView，可以控制子controller的显示区域
 *  同时，该类还支持定制的子controller切换效果
 */
@interface NIPContainerViewController : NIPBaseViewController

@property (nonatomic, weak) id<NTContainerViewControllerDelegate>delegate;
@property (nonatomic, copy, readonly) NSArray *viewControllers;
@property (nonatomic, weak,readonly) UIViewController *selectedViewController;

@property (nonatomic, strong,readonly,) UIView *containerView; //子controller.view的父view
@property(nonatomic) NSInteger defaultSelectedViewControllerIndex; //view加载时，默认显示的子controller index
@property(nonatomic) BOOL usingSelectedViewControllerNavigationItem; //是否显示子controller的navigationItem

/**
 *  Designated initializer.
 *
 *  @param viewControllers
 *
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;


- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated;

- (void)setSelectedViewControllerByIndex:(NSInteger)index animated:(BOOL)animated;

@end

/**
 *  NIPContainerViewController默认的UIViewControllerAnimatedTransitioning
 *  如果想使用自定义的UIViewControllerAnimatedTransitioning，请从这个类继承
 */
@interface NTDefaultAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end


@protocol NTContainerViewControllerDelegate <NSObject>
@optional
- (void)containerViewController:(NIPContainerViewController *)containerViewController
        didSelectViewController:(UIViewController *)viewController;

- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(NIPContainerViewController *)containerViewController
                   animationControllerForTransitionFromViewController:(UIViewController *)fromViewController
                                                     toViewController:(UIViewController *)toViewController;
@end
