 //
//  NIPNavigationController.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPNavigationController.h"

@interface NIPNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isInTransition;
@property (nonatomic, weak) id<UINavigationControllerDelegate> outerDelegate;
@property (nonatomic, assign) NSInteger currentViewControllersConut;

@end


@implementation NIPNavigationController


- (instancetype)init {
    return [self initWithRootViewController:[UIViewController new]];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.delegate = self;
        self.interactivePopGestureRecognizer.delegate = self;
        
        //对于ios7以上的系统，需要处理滑动手势事件，可能出现滑动一半又取消的状况
        //此时UINavigationControllerDelegate只会调用willShowViewController，而不会调用didShowViewController
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
            [self.interactivePopGestureRecognizer addTarget:self action:@selector(interactiveGestureAction:)];
        }
    }
    return self;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (delegate != self) {
        self.outerDelegate = delegate;
    } else {
        [super setDelegate:delegate];
    }
}


/**
 *  如果animated==NO，就不要设置isInTransition状态，因为连续的push调用在animated参数为NO的时候是合法的
 *  下面的所有方法都遵循这个策略
 *
 *  @param viewController
 *  @param animated
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isInTransition) {
        return;
    }
    self.isInTransition = animated;
    [super pushViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if (self.isInTransition) {
        return;
    }
    self.isInTransition = animated;
    return [super setViewControllers:viewControllers animated:animated];
}


/**
 *  在ios7这块有bug，如果被pop的controller的Orientation与下面的controller不一致，UINavigationControllerDelegate不会被调用
 *  因此加了个一个判断，如果pop之后orientation会发生改变，就不在设置isIntransition状态
 */

- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    if (self.currentViewControllersConut != self.viewControllers.count) {
        self.currentViewControllersConut = self.viewControllers.count;
        self.isInTransition = NO;
    }
    if (self.isInTransition) {
        return nil;
    }
    UIInterfaceOrientation currentOrientation = self.interfaceOrientation;
    UIViewController *popedViewController = [super popViewControllerAnimated:animated];
    self.isInTransition = animated&&popedViewController&&[self orientationWillNotChangeAfterTransition:currentOrientation];
    return popedViewController;
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated {
    if (self.isInTransition) {
        return @[];
    }
    
    UIInterfaceOrientation currentOrientation = self.interfaceOrientation;
    NSArray *popedControllers =  [super popToRootViewControllerAnimated:animated];
    self.isInTransition = animated&&(popedControllers.count>0)&&[self orientationWillNotChangeAfterTransition:currentOrientation];
    return popedControllers;
}

- (NSArray*)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isInTransition) {
        return @[];
    }
    UIInterfaceOrientation currentOrientation = self.interfaceOrientation;
    NSArray *popedControllers =  [super popToViewController:viewController animated:animated];;
    self.isInTransition = animated&&(popedControllers.count>0)&&[self orientationWillNotChangeAfterTransition:currentOrientation];
    return popedControllers;
}


- (BOOL)orientationWillNotChangeAfterTransition:(UIInterfaceOrientation)currentOrientation {
    UIInterfaceOrientationMask supportedOrientations = [self.navigationController supportedInterfaceOrientations];
    return supportedOrientations&(1<<currentOrientation);
}


#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSLog(@"view controller :%@  will show ", viewController);
    self.currentViewControllersConut = self.viewControllers.count;
    if (animated) {
        self.isInTransition = YES;
    }
    if (self.outerDelegate &&
        [self.outerDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.outerDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSLog(@"view controller :%@  did show ", viewController);
    self.isInTransition = NO;
    if (self.outerDelegate &&
        [self.outerDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.outerDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}


//这个方法是在手势将要激活前调用：返回YES允许侧滑手势的激活，返回NO不允许侧滑手势的激活
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //首先在这确定是不是我们需要管理的侧滑返回手势
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.interactivePopGestureRecognizer.enabled) {
            if (self.viewControllers.count > 1) {
                return YES;
            }
        }
        return NO; 
    }
    
    //这里就是非侧滑手势调用的方法啦，统一允许激活
    return YES;
}

- (void)interactiveGestureAction:(UIGestureRecognizer*)gesture {
    if (gesture.state==UIGestureRecognizerStateEnded ||
        gesture.state==UIGestureRecognizerStateCancelled) {
        NSLog(@"gesture end %@ ", gesture.view);
        self.isInTransition = NO;
    }
}

@end



