//
//  NIPContainerViewController.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPContainerViewController.h"

NSString *const UITransitionContextFromViewControllerKey_BackCompatible = @"NTTransitionContextFromViewControllerKey";
NSString *const UITransitionContextToViewControllerKey_BackCompatible = @"NTTransitionContextToViewControllerKey";

@interface NTContainerTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController
                                goingRight:(BOOL)goingRight; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@end

@interface NTDefaultAnimatedTransition()
- (void)nonAmimatedTransition:(id<UIViewControllerContextTransitioning>)transitionContext;
@end

#pragma mark -

@interface NIPContainerViewController ()
@property (nonatomic, copy, readwrite) NSArray *viewControllers;
@property (nonatomic, strong,readwrite) UIView *containerView; /// The view hosting the child view controllers views.
@end

@implementation NIPContainerViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
	NSParameterAssert ([viewControllers count] > 0);
	if ((self = [super init])) {
		self.viewControllers = [viewControllers copy];
	}
	return self;
}

- (id)init {
    @throw [NSException exceptionWithName:@"NIPContainerViewController"
                                   reason:@"you should using initWithViewControllers"
                                 userInfo:nil];
}

- (void)loadView {
    [super loadView];
	
	self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.containerView.opaque = YES;
    [self.view addSubview:self.containerView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.selectedViewController = (self.selectedViewController ?: self.viewControllers[self.defaultSelectedViewControllerIndex]);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
	return self.selectedViewController;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated {
    NSParameterAssert (selectedViewController);
	[self transitionToChildViewController:selectedViewController animated:animated];
	_selectedViewController = selectedViewController;
}

- (void)setSelectedViewControllerByIndex:(NSInteger)index animated:(BOOL)animated {
    [self setSelectedViewController:self.viewControllers[index] animated:animated];
}

-(void)setSelectedViewController:(UIViewController *)selectedViewController {
    [self setSelectedViewController:selectedViewController animated:NO];
}

#pragma mark Private Methods

- (void)transitionToChildViewController:(UIViewController *)toViewController animated:(BOOL)animated {
	
	UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
	if (toViewController == fromViewController || ![self isViewLoaded]) {
		return;
	}
	
	UIView *toView = toViewController.view;
	[toView setTranslatesAutoresizingMaskIntoConstraints:YES];
	toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	toView.frame = self.containerView.bounds;
	
	[fromViewController willMoveToParentViewController:nil];
	[self addChildViewController:toViewController];
	
	// If this is the initial presentation, add the new child with no animation.
	if (!fromViewController) {
		[self.containerView addSubview:toViewController.view];
		[toViewController didMoveToParentViewController:self];
        [self didCompleteTransitionToController:toViewController];
		return;
	}
	
    NTDefaultAnimatedTransition *animator = nil;
	if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
		animator = [self.delegate containerViewController:self
       animationControllerForTransitionFromViewController:fromViewController
                                         toViewController:toViewController];
	}
	animator = (animator?: [[NTDefaultAnimatedTransition alloc] init]);
	
	// Because of the nature of our view controller, with horizontally arranged buttons, we instantiate our private transition context with information about whether this is a left-to-right or right-to-left transition. The animator can use this information if it wants.
	NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
	NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
	NTContainerTransitionContext *transitionContext = [[NTContainerTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight:toIndex > fromIndex];
	
	transitionContext.animated = YES;
	transitionContext.interactive = NO;
	transitionContext.completionBlock = ^(BOOL didComplete) {
		[fromViewController.view removeFromSuperview];
		[fromViewController removeFromParentViewController];
		[toViewController didMoveToParentViewController:self];
		
		if ([animator respondsToSelector:@selector (animationEnded:)]) {
			[animator animationEnded:didComplete];
		}
        
        [self didCompleteTransitionToController:toViewController];
	};
    if (animated) {
        [animator animateTransition:transitionContext];
    } else {
        [animator nonAmimatedTransition:transitionContext];
    }
}

- (void)didCompleteTransitionToController:(UIViewController*)controller {
    if (self.usingSelectedViewControllerNavigationItem) {
        self.navigationItem.leftBarButtonItem = controller.navigationItem.leftBarButtonItem;
        self.navigationItem.title = controller.navigationItem.title;
        self.navigationItem.rightBarButtonItem = controller.navigationItem.rightBarButtonItem;
        self.navigationItem.titleView = controller.navigationItem.titleView;
    }
    
    if ([self.delegate respondsToSelector:@selector(containerViewController:didSelectViewController:)]) {
        [self.delegate containerViewController:self didSelectViewController:controller];
    }
}

@end

#pragma mark - Private Transitioning Classes

@interface NTContainerTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation NTContainerTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
	NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
	
	if ((self = [super init])) {
		self.presentationStyle = UIModalPresentationCustom;
		self.containerView = fromViewController.view.superview;

        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey_BackCompatible:fromViewController,
                                        UITransitionContextToViewControllerKey_BackCompatible:toViewController,
                                        };
        
		// Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
		CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
		self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
		self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
		self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
	}
	
	return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey_BackCompatible]) {
		return self.privateDisappearingFromRect;
	} else {
		return self.privateAppearingFromRect;
	}
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey_BackCompatible]) {
		return self.privateDisappearingToRect;
	} else {
		return self.privateAppearingToRect;
	}
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
	return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
	if (self.completionBlock) {
		self.completionBlock (didComplete);
	}
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}
@end

@implementation NTDefaultAnimatedTransition

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

- (void)nonAmimatedTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey_BackCompatible];
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
	[[transitionContext containerView] addSubview:toViewController.view];
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	return 0.5;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey_BackCompatible];
	UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey_BackCompatible];
	
	// When sliding the views horizontally in and out, figure out whether we are going left or right.
	BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x < [transitionContext finalFrameForViewController:toViewController].origin.x);
	CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
	CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
    
	[[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformInvert (travel);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0 usingSpringWithDamping:kDamping
          initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
              fromViewController.view.transform = travel;
              fromViewController.view.alpha = 0;
              toViewController.view.transform = CGAffineTransformIdentity;
              toViewController.view.alpha = 1;
            }
                     completion:^(BOOL finished) {
                         fromViewController.view.transform = CGAffineTransformIdentity;
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end


