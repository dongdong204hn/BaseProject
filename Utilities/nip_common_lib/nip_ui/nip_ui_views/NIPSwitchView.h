//
//  NIPSwitchView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPControl.h"

/**
 *  UITabBar的自定义版本
 */
@interface NIPSwitchView : NIPControl

@property(nonatomic,strong) NSArray *itemArray;
@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,strong) UIImage *backgroundImage;
@property(nonatomic,assign) UIEdgeInsets edgeInsets;

@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIColor *highlightTextColor;
@property(nonatomic,strong) UIColor *highlightTextShadowColor;
@property(nonatomic,strong) UIFont *textFont;
@property(nonatomic,strong) UIFont *highlightTextFont;

@property(nonatomic,strong) UIImage *thumbImage;
@property(nonatomic) UIEdgeInsets thumbImageShadow;
@property(nonatomic) BOOL enableSwitch;

@end
