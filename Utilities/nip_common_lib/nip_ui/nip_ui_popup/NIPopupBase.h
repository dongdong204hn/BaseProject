//
//  NIPopupBase.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZBPopupViewOnCloseBlock)();

typedef NS_ENUM(NSInteger, ZBAPopupAnmiationType) {
    ZBPopupAnmiationNone,
    ZBPopupAnmiationFade
};

/**
 *  弹出浮层，通过属性contentView来设置弹出浮层的基类，
 *  相比于ZBCustomAlertView，浮层不是独立的窗口，必须在一个container view里面显示
 */
@interface NIPopupBase : UIView

@property(nonatomic) ZBAPopupAnmiationType animationType; //default ZBPopupAnmiationFade
@property(nonatomic,copy) ZBPopupViewOnCloseBlock onCloseBlock; //关闭的时候，回调block

/**
 *  设置popup需要显示的主体内容，NIPopupBase不会构建相关的view hierarchy，子类需要重载这个方法
 *  子类如果重载这个方法，请先调用[super setContentView];
 *
 *  @param contentView
 */
- (void)setContentView:(UIView*)contentView;
- (UIView*)contentView;


/**
 *  在一个view中显示
 */
- (void)showInView:(UIView*)view;

/**
 *  showInController相当于[showInView:controller.view]
 */
- (void)showInController:(UIViewController*)controller;


- (void)close;
- (void)closeAfterTimeInterval:(NSTimeInterval)interval;



// override points

/**
 *  子类通过重写下面两个方法来定制animation，animation结束时，需要调用complete block，即使没有实际的动画，这个complete不会是nil
 *
 *  @param complete
 */
- (void)doShowAnimationOnComplete:(void (^)(void))complete;
- (void)doCloseAnimationOnComplete:(void (^)(void))complete;
@end
