//
//  NIPSlideViewController.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSlideViewController.h"
#import "UIView+NIPBasicAdditions.h"

@interface NIPSlideViewController ()
@property(nonatomic,weak) UIViewController *showingController;
@property(nonatomic,weak) UIViewController *rightViewController;
@property(nonatomic,weak) UIViewController *leftViewController;
@end

@implementation NIPSlideViewController {
    UIPanGestureRecognizer *_panGesture;
    UITapGestureRecognizer *_tapGesture;
    BOOL _inSlideTransition;
}

- (void)loadView {
    [super loadView];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(viewPanned:)];
    _panGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:_panGesture];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(viewTapped:)];
    _tapGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:_tapGesture];
    
    self.view.clipsToBounds = YES;
    [self prepareViewControllerForShow:self.showingController];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.mainViewController preferredStatusBarStyle];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.mainViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.mainViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate {
    return [self.mainViewController shouldAutorotate];
}

- (void)removeChildController:(UIViewController*)childController {
    [childController removeFromParentViewController];
    if ([childController isViewLoaded]) {
        [childController.view removeFromSuperview];
    }
}

- (void)setShowingController:(UIViewController *)showingController {
    _showingController = showingController;
    
    if (_showingController!=_mainViewController) {
        _mainViewController.view.userInteractionEnabled = NO;
    } else {
        _mainViewController.view.userInteractionEnabled = YES;
    }
}

- (BOOL)isShowingMainViewController {
    return _showingController==_mainViewController;
}

- (void)setMainViewController:(UIViewController *)mainViewController {
    [self removeChildController:self.mainViewController];
    
    _mainViewController = mainViewController;
    if (mainViewController) {
        [self addChildViewController:mainViewController];
        self.showingController = mainViewController;
        [self prepareViewControllerForShow:mainViewController];
    }
}


- (UIViewController*)rightViewController {
    UIViewController *rightController = [self.delegate rightControllerOfSideViewController:self];
    if  (rightController!=_rightViewController) {
        [self removeChildController:_rightViewController];
        _rightViewController = rightController;
        if (_rightViewController) {
            [self addChildViewController:_rightViewController];
        }
    }
    return _rightViewController;
}


- (void)showRightViewController {
    [self showViewController:self.rightViewController];
}
- (void)showMainViewController {
    [self showViewController:self.mainViewController];
}
- (void)showLeftViewController {
    [self showViewController:self.leftViewController];
}

- (CGFloat)xoffsetShowController:(UIViewController*)controller {
    if (self.leftViewController&&controller==self.leftViewController) {
        return 320-self.marginSpace;
    } else if (self.rightViewController&&controller==self.rightViewController) {
        return -320+self.marginSpace;
    } else {
        return 0;
    }
}

- (void)prepareViewControllerForShow:(UIViewController*)controller {
    if (![self isViewLoaded]) {
        return;
    }
    if (![controller isViewLoaded]||([controller.view superview]!=self.view)) {
        [controller beginAppearanceTransition:true animated:false];
        CGRect viewFrame = self.view.bounds;
        if (controller==self.leftViewController) {
            viewFrame = CGRectMake(0, 0, viewFrame.size.width-self.marginSpace, viewFrame.size.height);
        } else if (controller==self.rightViewController) {
            viewFrame = CGRectMake(self.marginSpace, 0, viewFrame.size.width-self.marginSpace, viewFrame.size.height);
        }
        controller.view.frame = viewFrame;
        [self.view addSubview:controller.view];
        [controller endAppearanceTransition];
    }
    [self.view bringSubviewToFront:_mainViewController.view];
    controller.view.hidden = NO;
    
    if (controller==self.leftViewController) {
        if (self.rightViewController&&[self.rightViewController isViewLoaded]) {
            self.rightViewController.view.hidden = YES;
        }
    } else if (controller==self.rightViewController) {
        if (self.leftViewController&&[self.leftViewController isViewLoaded]) {
            self.leftViewController.view.hidden = YES;
        }
    }
}

- (UIViewController*)leftViewController {
    UIViewController *leftController = [self.delegate leftControllerOfSideViewController:self];
    if  (leftController!=_leftViewController) {
        [self removeChildController:_leftViewController];
        _leftViewController = leftController;
        if (_leftViewController) {
            [self addChildViewController:_leftViewController];
        }
    }
    return _leftViewController;
}


- (void)showViewController:(UIViewController*)viewController {
    if (!viewController||_inSlideTransition) {
        return;
    }
      CGFloat xOffSet = [self xoffsetShowController:viewController];
    
    if  (_mainViewController.view.left!=xOffSet
         ||self.showingController!=viewController) {
        BOOL viewShouldDissAppear = NO;
        BOOL viewShouldAppear = NO;
        if (self.showingController!=viewController
            &&self.showingController!=self.mainViewController) {
            viewShouldDissAppear = YES;
            [self.showingController beginAppearanceTransition:NO animated:YES];
        }
        if ([viewController isViewLoaded]
            &&viewController!=self.mainViewController) {
            viewShouldAppear = YES;
            [viewController beginAppearanceTransition:YES animated:YES];
        }
        
        [self prepareViewControllerForShow:viewController];
        
        _inSlideTransition = YES;
        NSTimeInterval interval = fabs(xOffSet-_mainViewController.view.left)/640.0f;
        [UIView animateWithDuration:interval
                         animations:^{
                             _mainViewController.view.left = xOffSet;
                         }
                         completion:^(BOOL finished) {
                             if (viewShouldDissAppear) {
                                 [self.showingController endAppearanceTransition];
                             }
                             if (viewShouldAppear) {
                                 [viewController endAppearanceTransition];
                             }
                             if (viewController==_mainViewController) {
                                 self.showingController.view.hidden = YES;
                             }
                             _mainViewController.view.hidden = NO;
                             self.showingController = viewController;
                             _inSlideTransition = NO;
                         }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_inSlideTransition) {
        return NO;
    }
    if (_tapGesture==gestureRecognizer) {
        CGPoint point = [_tapGesture locationInView:self.view];
        if (!self.isShowingMainViewController
            && CGRectContainsPoint(self.mainViewController.view.frame,point)) {
            return YES;
        }
    } else if(_panGesture==gestureRecognizer) {
        CGPoint trans = [_panGesture translationInView:self.view];
        if (fabs(trans.x)>fabs(trans.y)) {
            if (self.showingController!=self.mainViewController) {
                return YES;
            }
            if (trans.x>0&&self.leftViewController) {
                return YES;
            } else if (self.rightViewController) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)viewTapped:(UITapGestureRecognizer*)sender {
    [self showMainViewController];
}

- (void)viewPanned:(UIPanGestureRecognizer*)pan {
    static UIViewController *targetController = nil;
    static CGPoint lastTrans = {0,0};
    static CGFloat clamfMinX = 0;
    static CGFloat clamfMaxX = 0;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            lastTrans = CGPointZero;
            targetController = [self preparePanGestureTargetcontroller:pan];
            if (!targetController) {
                return;
            }
            
            CGFloat xOffset1 = [self xoffsetShowController:self.leftViewController];
            CGFloat xOffset2 = [self xoffsetShowController:self.rightViewController];
            clamfMinX = MIN(xOffset1, xOffset2);
            clamfMaxX = MAX(xOffset1, xOffset2);
            
            CGPoint trans = [pan translationInView:self.view];
            CGFloat newLeft = _mainViewController.view.left+(trans.x-lastTrans.x);;
            newLeft = clampf(newLeft, clamfMinX, clamfMaxX);
            _mainViewController.view.left = newLeft;
            lastTrans = trans;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            targetController = [self preparePanGestureTargetcontroller:pan];
            if (!targetController) {
                return;
            }
            
            CGPoint trans = [pan translationInView:self.view];
            CGFloat newLeft = _mainViewController.view.left+(trans.x-lastTrans.x);;
            newLeft = clampf(newLeft, clamfMinX, clamfMaxX);
            _mainViewController.view.left = newLeft;
            lastTrans = trans;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (!targetController) {
                return;
            }
            if (fabs([pan velocityInView:self.view].x)>200) {
                if ([pan velocityInView:self.view].x>200) { //right pan
                    if (targetController==self.rightViewController) {
                        [self showMainViewController];
                    } else {
                        [self showLeftViewController];
                    }
                }
                if ([pan velocityInView:self.view].x<-200) { //left pan
                    if (targetController==self.rightViewController) {
                        [self showRightViewController];
                    } else {
                        [self showMainViewController];
                    }
                }
            } else {
                if (targetController==self.rightViewController&&_mainViewController.view.left<-160) {
                    [self showRightViewController];
                } else if (targetController==self.leftViewController&&_mainViewController.view.left>160) {
                    [self showLeftViewController];
                } else {
                    [self showMainViewController];
                }
            }
            break;
        default:
            break;
    }
}

- (UIViewController*)preparePanGestureTargetcontroller:(UIPanGestureRecognizer*)pan {
    CGPoint trans = [pan translationInView:self.view];
    if (fabs(trans.x)<2.0) {
        return nil;
    }
    
    UIViewController *targetController = nil;
    if (self.showingController!=_mainViewController) {
        targetController = self.showingController;
    } else {
        if (trans.x>0&&self.leftViewController) {
            targetController = self.leftViewController;
        }
        if (trans.x<0&&self.rightViewController) {
            targetController = self.rightViewController;
        }
    }
    if (targetController) {
        [self prepareViewControllerForShow:targetController];
    }
    return targetController;
}


@end
