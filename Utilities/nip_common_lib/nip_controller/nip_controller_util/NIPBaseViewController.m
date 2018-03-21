//
//  NIPBaseViewController.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseViewController.h"
#import "MBProgressHUD.h"
#import "UIView+NIPBasicAdditions.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "NIPUIFactory.h"
#import "nip_macros.h"

@interface ControllerView : UIView

- (void)enbleBackgroundTapToResignFirstResponder:(BOOL)enable;

@end

@implementation ControllerView {
    UITapGestureRecognizer *_gesture;
}

- (void)enbleBackgroundTapToResignFirstResponder:(BOOL)enable
{
    if (enable && !_gesture) {
        _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        _gesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_gesture];
    }
    else {
        [self removeGestureRecognizer:_gesture];
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    UIView *view = [self hitTest:point withEvent:nil];
    if ([view isKindOfClass:[UIButton class]]) {
        UIView *superView = [view superview];
        if ([superView isKindOfClass:[UITextField class]]) { //是textField 上面的清除按钮则 不收起键盘
            return;
        }
    }
    [[self findFirstResponder] resignFirstResponder];
}

@end


@interface NIPBaseViewController ()

@property (nonatomic, strong) UILabel *naviTitleLabel;
@property (nonatomic, strong) UINavigationItem *privateNavigationItem;

@property (nonatomic, strong) UILabel *tileLabel;
@property (nonatomic, strong) UIView *disPlayIndicatorView;

@end

#define NTLoadingProgressViewTag (10001)

@implementation NIPBaseViewController

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _firstAppear = YES;
        
        if ([UIDevice systemMainVersion] >= 7) {
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.hidesBottomBarWhenPushed = YES;
        self.titleColor = [UIColor whiteColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _firstAppear = YES;
}

- (void)changeStatus {
    _firstAppear = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    [CFPageEvent openPage:NSStringFromClass([self class])];
    // Do any additional setup after loading the view.
    [self addContentView];
    [self setNaviLeftViewIfNeeded];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [[CFRoutine sharedScheduler] saveClassNamed:self.class];
    _isAppearing = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.naviRightView setUserInteractionEnabled:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(changeStatus) withObject:nil afterDelay:0.0f];
}

- (void)appEnterBackground:(NSNotification *)note {
    [self.contentView endEditing:YES];
}

- (void)appEnterForeground:(NSNotification *)note {
}


- (void)viewWillDisappear:(BOOL)animated
{
    _isAppearing = NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    if (self.isViewLoaded) {
        //        [CFPageEvent closePage:NSStringFromClass([self class])];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    LOG(@"%@:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}


#pragma mark - 事件监听

-(void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - UI control 

-(void)addContentView {
    _contentView = [[ControllerView alloc] initWithFrame:self.view.bounds];
    _contentView.backgroundColor = [NIPUIFactory contentViewBackgroundColor];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:_contentView atIndex:0];
    
    NSDictionary *bindingDict = NSDictionaryOfVariableBindings(_contentView);
    NSString *HorizitalVFL = @"H:|[_contentView]|"; NSArray *HorizitalArr = [NSLayoutConstraint constraintsWithVisualFormat:HorizitalVFL options:0 metrics:nil views:bindingDict];
    [self.view addConstraints:HorizitalArr];
    NSString *VerticalVFL = @"V:|[_contentView]|"; NSArray *VerticalArr = [NSLayoutConstraint constraintsWithVisualFormat:VerticalVFL options:0 metrics:nil views:bindingDict];
    [self.view addConstraints:VerticalArr];
}

-(void)setNaviLeftViewIfNeeded {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        if (self.naviLeftView) {
            [self.naviLeftView setHidden:NO];
        } else {
            self.naviLeftView = [NIPUIFactory buttonWithImage:[self imageForNaviLeftView] target:self selector:@selector(baseBackButtonPressed:)];
        }
    } else {
        if (self.naviLeftView) {
            [self.naviLeftView setHidden:YES];
        }
    }
}


#pragma mark - 旋转控制

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationPortrait == toInterfaceOrientation;
}

- (void)setEnableBackgroundTapToResignFirstResponder:(BOOL)enableBackgroundTapToResignFirstResponder
{
    [(ControllerView *)_contentView enbleBackgroundTapToResignFirstResponder:enableBackgroundTapToResignFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - action code

- (void)baseBackButtonPressed:(id)sender {
    [self baseBackButtonPressed:sender animated:YES];
}

- (void)baseBackButtonPressed:(id)sender animated:(BOOL)animated {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:animated];
    }
    else {
        [[self presentingViewController] dismissViewControllerAnimated:animated completion:nil];
    }
}


#pragma mark - loadingIndicator 显示

- (void)showLoadingIndicator {
    [self showLoadingIndicatorWithText:nil];
}

- (void)showLoadingIndicatorWithText:(NSString *)text
{
    MBProgressHUD *progressView = (MBProgressHUD *)[self.disPlayIndicatorView viewWithTag:NTLoadingProgressViewTag];
    if (!progressView) {
        progressView = [MBProgressHUD showHUDAddedTo:self.disPlayIndicatorView animated:YES];
        progressView.mode = MBProgressHUDModeCustomView;
        
        progressView.bezelView.alpha = 0.4;
        progressView.margin = 8;
        UIImageView *animationImageVw = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        NSMutableArray *imageArr = [[NSMutableArray alloc] init];
        for (int i = 1; i < 9; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_%02d.png", i]];
            [imageArr addObject:image];
        }
        animationImageVw.animationImages = imageArr;
        animationImageVw.animationDuration = 0.3;
        [animationImageVw startAnimating];
        progressView.customView = animationImageVw;
        progressView.tag = NTLoadingProgressViewTag;
        progressView.layer.zPosition = 0.1;
    }
    progressView.label.text = text;
}

- (void)dismissLoadingIndicator
{
    MBProgressHUD *progressView = (MBProgressHUD *)[self.disPlayIndicatorView viewWithTag:NTLoadingProgressViewTag];
    if (progressView) {
        [progressView hideAnimated:YES];
    }
}


#pragma mark - toast 显示


- (void)showToastAtKeyWindow:(NSString *)text
{
    if (text && text.length > 0) {
        NSTimeInterval showDuration = MAX(2.0, text.length / 10.0f);
        [[UIApplication sharedApplication].keyWindow makeToast:text duration:showDuration position:CSToastPositionCenter];
    }
}

- (void)showToastAtKeyWindow:(NSString *)text WithCenter:(CGPoint)point
{
    if (text && text.length > 0) {
        NSTimeInterval showDuration = MAX(2.0, text.length / 10.0f);
        [[UIApplication sharedApplication].keyWindow makeToast:text duration:showDuration position:[NSValue valueWithCGPoint:point]];
    }
}

- (void)showToastAtKeyWindowWithSuccess:(NSString *)text
{
    if (text && text.length > 0) {
        NSTimeInterval showDuration = MAX(2.0, text.length / 10.0f);
        [[UIApplication sharedApplication].keyWindow makeToast:text duration:showDuration position:CSToastPositionCenter image:[UIImage imageNamed:@"success"]];
    }
}

- (void)showToast:(NSString *)text
{
    if (text && text.length > 0) {
        NSTimeInterval showDuration = MAX(2.0, text.length / 10.0f);
        [self.contentView makeToast:text duration:showDuration position:CSToastPositionCenter];
    }
}

- (void)showToast:(NSString *)text WithCenter:(CGPoint)point
{
    if (text && text.length > 0) {
        NSTimeInterval showDuration = MAX(2.0, text.length / 10.0f);
        [self.contentView makeToast:text duration:showDuration position:[NSValue valueWithCGPoint:point]];
    }
}

- (void)showToastWithSuccess:(NSString *)text
{
    if (text && text.length > 0) {
        NSTimeInterval showDuration = MAX(2.0, text.length / 10.0f);
        [self.contentView makeToast:text duration:showDuration position:CSToastPositionCenter image:[UIImage imageNamed:@"success"]];
    }
}




#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    if ([self.naviTitleLabel.text isEqualToString:title]) {
        return;
    }
    CGSize maxLabelSize = CGSizeMake(180,CGFLOAT_MAX);
    CGSize textSize = [title boundingRectWithSize:maxLabelSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.naviTitleLabel.font} context:nil].size;
    self.naviTitleLabel.frame = CGRectMake(([UIDevice screenWidth] - textSize.width) / 2, 0, textSize.width, 44);
    self.naviTitleLabel.text = title;
    if (self.naviTitleView == nil) {
        self.naviTitleView = self.naviTitleLabel;
    }
}

- (void)setNaviLeftView:(UIView *)naviLeftView {
    UINavigationItem *navigationItem = [self getPropertyNavigationItem];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:naviLeftView];
}

- (void)setNaviTitleView:(UIView *)naviTitleView {
    UINavigationItem *navigationItem = [self getPropertyNavigationItem];
    if (navigationItem.titleView == self.naviTitleLabel && naviTitleView == nil) {
        return;
    }
    navigationItem.titleView = naviTitleView;
}

- (void)setNaviRightView:(UIView *)naviRightView {
    UINavigationItem *navigationItem = [self getPropertyNavigationItem];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:naviRightView];
}


#pragma mark - Getters

- (UIView *)disPlayIndicatorView {
    if (!_disPlayIndicatorView) {
        if (self.isNotIndependent) {
            UIViewController *controller = [self topmostViewController];
            _disPlayIndicatorView = controller.view;
        }
        else {
            _disPlayIndicatorView = self.contentView;
        }
    }
    return _disPlayIndicatorView;
}

- (NSString *)title {
    return self.naviTitleLabel.text;
}

- (UINavigationItem *)getPropertyNavigationItem {
    if (self.usingPrivateNavigationItem) {
        return self.privateNavigationItem;
    } else {
        return self.navigationItem;
    }
}

- (UIView *)naviLeftView {
    UINavigationItem *navigationItem = [self getPropertyNavigationItem];
    return navigationItem.leftBarButtonItem.customView;
}

- (UIView *)naviTitleView {
    UINavigationItem *navigationItem = [self getPropertyNavigationItem];
    if (self.naviTitleLabel == navigationItem.titleView) {
        return nil;
    }
    return navigationItem.titleView;
}

- (UIView *)naviRightView {
    UINavigationItem *navigationItem = [self getPropertyNavigationItem];
    return navigationItem.rightBarButtonItem
    .customView;
}

- (UILabel *)naviTitleLabel {
    if (!_naviTitleLabel) {
        _naviTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 100, 44)];
        _naviTitleLabel.backgroundColor = [UIColor clearColor];
        _naviTitleLabel.font = [UIFont systemFontOfSize:21];
        if ([_naviTitleLabel respondsToSelector:@selector(minimumScaleFactor)]) {
            _naviTitleLabel.minimumScaleFactor = 0.8;
        }
        _naviTitleLabel.textColor = self.titleColor;
        _naviTitleLabel.shadowColor = self.titleShadowColor;
        _naviTitleLabel.shadowOffset = CGSizeMake(1, 1);
        _naviTitleLabel.textAlignment = NSTextAlignmentCenter;
        _naviTitleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _naviTitleLabel;
}

- (UIViewController *)getControllerInstanceOfClass:(Class)class {
    if (self.navigationController) {
        __block UIViewController *targetVC = nil;
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:class]) {
                targetVC = obj;
                *stop = YES;
            }
        }];
        return targetVC;
    }
    return nil;
}

- (BOOL)navigationControllerContainInstanceOfClass:(Class) class
{
    __block BOOL isContain = NO;
    if (self.navigationController) {
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:class]) {
                isContain = YES;
                *stop = YES;
            }
        }];
    }
    return isContain;
}

#pragma mark - notification support
- (void)observeNotificationOfName:(NSString *)noteName
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:noteName
                                               object:nil];
}

- (void)observeNotificationOfName:(NSString *)noteName fromObject:(NSObject *)object
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:noteName
                                               object:object];
}

- (void)stopObserveNotificationOfName:(NSString *)noteName
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noteName object:nil];
}

- (void)stopObserveAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveNotification:(NSNotification *)note
{
}

#pragma mark - NIPBaseViewControllerDelegate
- (UIViewController *)topmostViewController {
    return self;
}

- (UIImage *)imageForNaviLeftView {
    return [UIImage imageNamed:@"nip_white_back_btn"];
}

@end
