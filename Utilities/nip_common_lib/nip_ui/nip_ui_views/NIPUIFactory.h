//
//  NIPUIFactoryChild.h
//  NSIP
//
//  Created by 赵松 on 16/12/5.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPUIFactory : NSObject


/**
 *  根据文本与图片生成包含文本与视图的可点击视图
 *
 *  @param text      文本
 *  @param fontSize  字体大小
 *  @param textColor 文本颜色
 *  @param img       图片
 *  @param selector  SEL
 *  @param target    实现selector的target
 *
 *  @return 包含文本与视图的可点击视图
 */
+ (UIView *)tappableViewWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor image:(UIImage *)image selector:(SEL)selector target:(id)target;

/**
 *  根据制定的图片、SEL和target生成可响应和拖动的悬浮框视图
 */
+ (UIImageView *)suspendImageViewWithImage:(UIImage *)image selector:(SEL)selector target:(id)target;

///----------------------------------
/// @name 获取字体
///----------------------------------

+ (UIFont *)fontWithSize:(CGFloat)fontSize;
+ (UIFont *)boldFontWithSize:(CGFloat)fontSize;

+ (UIFont *)numberFontOfSize:(CGFloat)size;


///----------------------------------
/// @name navigationbar
///----------------------------------
+ (void)setNormalBackgroundImage:(UIImage *)image toNavigationBar:(UINavigationBar *)navigationBar;
//+ (void)setNormalBackgroundImageToNavigationBar:(UINavigationBar *)navigationBar;


///----------------------------------
/// @name button
///----------------------------------

+ (UIButton *)buttonWithFrame:(CGRect)frame;

+ (UIButton *)buttonWithTitle:(NSString *)title
                       target:(id)target
                     selector:(SEL)selector;
+ (UIButton *)buttonWithTitle:(NSString *)title
                     fontSize:(CGFloat)size
                       target:(id)target
                     selector:(SEL)selector;
+ (UIButton *)buttonWithWhiteTitle:(NSString *)title
                          fontSize:(CGFloat)fontSize
                            target:(id)target
                          selector:(SEL)selector;

+ (UIButton *)buttonWithImage:(UIImage *)image;
+ (UIButton *)buttonWithImage:(UIImage *)image
                       target:(id)target
                     selector:(SEL)selector;
+ (UIButton *)buttonWithBackImage:(UIImage *)image
                            title:(NSString *)title
                         fontSize:(CGFloat)fontSize;
+ (UIButton *)buttonWithBackImage:(UIImage *)image
                            title:(NSString *)title
                         fontSize:(CGFloat)fontSize
                           target:(id)target
                         selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image
                        title:(NSString *)title
                     fontSize:(CGFloat)fontSize
                       target:(id)target
                     selector:(SEL)selector;


+ (UIButton *)naviButtonWithTitle:(NSString *)title
                           target:(id)target
                         selector:(SEL)selector;
+ (UIButton *)navigationButtonForImage:(UIImage *)image
                                target:(id)target
                              selector:(SEL)selector;

/**
 *  通过NIPUIFactoryChild生成常用UILabel控件
 */
+ (UILabel *)labelWithFontSize:(CGFloat)fontSize;
+ (UILabel *)labelWithFontSize:(CGFloat)fontSize andTextColor:(UIColor *)textColor;
+ (UILabel *)labelWithText:(NSString *)text andFontSize:(CGFloat)fontSize;
+ (UILabel *)labelWithText:(NSString *)text fontSize:(CGFloat)fontSize andTextColor:(UIColor *)textColor;
+ (UILabel *)labelWithText:(NSString *)text boldFont:(CGFloat)fontsize textColor:(UIColor *)textColor;
+ (UILabel *)labelForNavTitle:(NSString *)title;


///----------------------------------
/// @name 获取 color
///----------------------------------


+ (UIColor *)grayTitleColor;
+ (UIColor *)grayContentColor;
+ (UIColor *)blackTextColor;
+ (UIColor *)blackTextColor1;
+ (UIColor *)blackTextColor2;
+ (UIColor *)orangeTextColor2;
+ (UIColor *)yellowTextColor;
+ (UIColor *)linkTextColor;
+ (UIColor *)blueTextColor;

+ (UIColor *)contentViewBackgroundColor;
+ (UIColor *)shadowColorForWhiteText;

@end
