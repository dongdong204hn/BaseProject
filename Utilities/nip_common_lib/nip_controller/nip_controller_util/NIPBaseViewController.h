//
//  NIPBaseViewController.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NIPBaseViewControllerDelegate <NSObject>

@required
- (UIViewController *)topmostViewController;

@optional
- (UIImage *)imageForNaviLeftView;

@end

/**
 *  NIPBaseViewController在UIViewController基础上提供了一些更加方便的接口
 */
@interface NIPBaseViewController : UIViewController <NIPBaseViewControllerDelegate>
#pragma mark - basic properties

@property(nonatomic, assign) BOOL usingPrivateNavigationItem;
@property(nonatomic, strong, readonly) UINavigationItem *privateNavigationItem;

@property(nonatomic, assign, readonly) BOOL firstAppear;

@property(nonatomic, strong) UIView *naviTitleView;
@property(nonatomic, strong) UIView *naviRightView;
@property(nonatomic, strong) UIView *naviLeftView;
@property(nonatomic, strong) UIColor *titleColor;
@property(nonatomic, strong) UIColor *titleShadowColor;


#pragma mark - addition properties

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, assign) BOOL isAppearing;                               //是否页面正在显示中
@property (nonatomic, assign) BOOL enableBackgroundTapToResignFirstResponder; //这个属性使得controller的rootview自动检测点击事件并将firstResponder取消，在包含有输入控件的controller里比较方便
@property (nonatomic, assign) BOOL isNotIndependent;  //是否是非独立的容器，比如是一个容器包含的子容器时，loadingview应该加在父容器上。
//@property (nonatomic, strong) CFErrorBaseView *errorView;             //每个界面的网络错误的时候呈现出来的界面


- (void)baseBackButtonPressed:(id)sender;
- (void)baseBackButtonPressed:(id)sender animated:(BOOL)animated;

- (void)showLoadingIndicator;
- (void)showLoadingIndicatorWithText:(NSString *)text;
- (void)dismissLoadingIndicator;
- (void)showToast:(NSString *)text;
- (void)showToast:(NSString *)text WithCenter:(CGPoint)point;
- (void)showToastWithSuccess:(NSString *)text;
- (void)showToastAtKeyWindow:(NSString *)text;
- (void)showToastAtKeyWindow:(NSString *)text WithCenter:(CGPoint)point;
- (void)showToastAtKeyWindowWithSuccess:(NSString *)text;


//- (void)showLoginControllerWithSuccessBlock:(void (^)())successBlock cancelBlock:(void (^)())cancelBlock;

- (void)appEnterForeground:(NSNotification *)note;

/**
 *  基于当前页面tableview的错误视图
 *
 *  @param errorMsg 错误内容
 */
//- (void)createErrorViewWithMessage:(NSString *)errorMsg;

/**
 *  基于contentview的错误视图
 *
 *  @param errorMsg 错误内容
 */
//- (void)createErrorViewAtContentViewWithMessage:(NSString *)errorMsg;

/**
 *  创建错误视图
 *
 *  @param errorMsg 错误信息
 *  @param view     加载错误视图的view
 *  @param action   刷新的方法
 */
//- (void)createErrorViewWithMessage:(NSString *)errorMsg
//                            atView:(UIView *)view
//                 withRefreshAction:(SEL)action;
/**
 *  显示空视图
 *
 *  @param emptyMsg  空视图消息内容
 *  @param image     空视图图片
 *  @param tableView 空视图加载的view
 */
//- (void)createEmptyViewWithMessage:(NSString *)emptyMsg
//                          AndImage:(UIImage*)image
//                       atTableView:(UITableView *)tableView;
//
//- (void)createErrorViewWithMessage:(NSString *)errorMsg
//                 withRefreshAction:(SEL)action;
/**
 *  在控制器栈中去寻找控制器
 *
 *  @param class 需要寻找的控制器名称
 *
 *  @return 返回需要寻找的控制器名称
 */
- (UIViewController *)getControllerInstanceOfClass:(Class) class;

- (BOOL)navigationControllerContainInstanceOfClass:(Class) class;

#pragma mark notification support
- (void)observeNotificationOfName:(NSString*)noteName;
- (void)observeNotificationOfName:(NSString*)noteName fromObject:(NSObject*)object;
- (void)stopObserveNotificationOfName:(NSString*)noteName;
- (void)stopObserveAllNotifications;
- (void)receiveNotification:(NSNotification*)note;

@end