//
//  NIPopupMaskView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPopupBase.h"

/**
 *  带一个背景蒙版的popupView
 */
@interface NIPopupMaskView : NIPopupBase
@property(nonatomic,strong) UIColor *maskColor; //default is black color with alpha 0.8

/**
 *  点击背景蒙板区域关闭该view, default is YES；
 *  如果contentView.userInteractionEnabled==YES，只有点击contentView以外的区域才会关闭，否则点击任何区域都关闭
 */
@property(nonatomic) BOOL wouldCloseByBackgroundtap;
@end
