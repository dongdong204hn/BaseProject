//
//  NIPScreenTipWindow.h
//  NSIP
//
//  Created by 赵松 on 16/12/13.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPCustomAlertBase.h"

typedef void(^NIPScreenTipWindowDidTap)(void);

//! 封装全屏半透明展示提示语的视图，只需要设置contentView即可，顶部有关闭按钮。基于UIWindow
@interface NIPScreenTipWindow : NIPCustomAlertBase

//! 跳转链接
//@property (nonatomic, copy) NSString *jumpUrlString;

//! 可以在块中进行页面跳转等操作
@property (nonatomic, copy) NIPScreenTipWindowDidTap didTapBlock;

//! 是否显示取消按钮。点击取消按钮不会跳转到指定链接
@property (nonatomic, assign) BOOL showCancelBtn;

+ (instancetype)tipView;

@end
