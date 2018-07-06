//
//  NIPScreenTipView.h
//  NSIP
//
//  Created by 赵松 on 16/12/13.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NIPScreenTipViewDidTap)(void);

/// 封装展示进行指引的全屏图片视图。基于UIView。
@interface NIPScreenTipView : UIView

///**
// *  显示活动图时，跳转url字符串
// */
//@property (nonatomic, copy) NSString *jumpUrlString;

/// 可以在块中进行页面跳转等操作
@property (nonatomic, copy) NIPScreenTipViewDidTap didTapBlock;
/// 显示的图片
@property (nonatomic, strong) UIImage *tipImage;
/// 是否显示取消按钮。点击取消按钮不会跳转到指定链接
@property (nonatomic, assign) BOOL showCancelBtn;
/// 是否已显示
@property (nonatomic, assign) BOOL isShow;
/// 显示时的背景色
@property (nonatomic, strong) UIColor *showColor;

+ (instancetype)tipView;

- (id)initWithImage:(UIImage*)image;

- (void)show;

@end
