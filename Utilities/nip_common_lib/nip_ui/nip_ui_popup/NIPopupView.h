//
//  NIPopupView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPopupBase.h"

/**
 *  弹出浮层, 默认animationType为ZBPopupAnmiationFade，不会阻碍背后的View被点击
 */
@interface NIPopupView : NIPopupBase

+ (void)showContentView:(UIView*)contentView inController:(UIViewController *)controller closeAfter:(NSTimeInterval)seconds;

@end
