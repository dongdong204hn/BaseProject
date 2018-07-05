//
//  NIPUIFactoryChild.m
//  NSIP
//
//  Created by 赵松 on 16/12/5.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPUIFactory.h"
#import "UIView+NIPBasicAdditions.h"
#import "nip_macros.h"
#import "NSString+NIPBasicAdditions.h"
#import "UIColor+NIPBasicAdditions.h"

@implementation NIPUIFactory

+ (UIView *)tappableViewWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor image:(UIImage *)image selector:(SEL)selector target:(id)target {
    UILabel *titleLabel = [self labelWithText:text fontSize:fontSize andTextColor:textColor];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    UIView *tappableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleLabel.width + 5.f + imgView.width, titleLabel.height > imgView.height ? titleLabel.height : imgView.height)];
    [tappableView addSubview:titleLabel];
    titleLabel.origin = CGPointMake(0, 0);
    [titleLabel centerVertical];
    [tappableView addSubview:imgView];
    imgView.left = titleLabel.right + 5.f;
    [imgView centerVertical];
    [tappableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:selector]];
    return tappableView;
}

+ (UIImageView *)suspendImageViewWithImage:(UIImage *)image selector:(SEL)selector target:(id)target {
    UIImageView *suspendView = [[UIImageView alloc] initWithImage:image];
    [suspendView setUserInteractionEnabled:YES];
    [suspendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:selector]];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSuspendView:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [suspendView addGestureRecognizer:panRecognizer];
    return suspendView;
}

+ (void)moveSuspendView:(UIPanGestureRecognizer *)recognizer {
    UIView *superView = recognizer.view.superview;
    float imgHalfWidth = recognizer.view.width / 2;
    float imgHalfHeight = recognizer.view.height / 2;
    CGPoint translatedPoint = [recognizer translationInView:superView];
    LOG(@"gesture translatedPoint  is %@", NSStringFromCGPoint(translatedPoint));
    CGFloat newCenter_X = recognizer.view.center.x + translatedPoint.x;
    newCenter_X = newCenter_X < imgHalfWidth ? imgHalfWidth : newCenter_X;
    newCenter_X = newCenter_X > superView.width - imgHalfWidth ? superView.width - imgHalfWidth : newCenter_X;
    CGFloat newCenter_Y = recognizer.view.center.y + translatedPoint.y;
    newCenter_Y = newCenter_Y < imgHalfHeight ? imgHalfHeight : newCenter_Y;
    newCenter_Y = newCenter_Y > superView.height - imgHalfHeight ? superView.height - imgHalfHeight : newCenter_Y;
    
    recognizer.view.center = CGPointMake(newCenter_X, newCenter_Y);
    
    LOG(@"pan gesture testPanView moving  is %@,%@", NSStringFromCGPoint(recognizer.view.center), NSStringFromCGRect(recognizer.view.frame));
    [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view.superview];
}


///----------------------------------
/// @name navigationbar
///----------------------------------

+ (void)setNormalBackgroundImage:(UIImage *)image toNavigationBar:(UINavigationBar *)navigationBar
{
    [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    if ([navigationBar respondsToSelector:@selector(setShadowImage:)]) {
        navigationBar.shadowImage = [[UIImage alloc] init];
    }
}


///----------------------------------
/// @name button
///----------------------------------

+ (UIButton *)buttonWithFrame:(CGRect)rect
{
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    button.exclusiveTouch = YES;
    return button;
}

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    return [self buttonWithTitle:title fontSize:18 target:target selector:selector];
}

+ (UIButton *)buttonWithTitle:(NSString *)title fontSize:(CGFloat)fontSize target:(id)target selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    button.titleLabel.font = font;
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    button.frame = CGRectMake(0, 0, textSize.width, fontSize + 5);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)buttonWithWhiteTitle:(NSString *)title fontSize:(CGFloat)fontSize target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    button.titleLabel.font = font;
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    button.frame = CGRectMake(0, 0, textSize.width, fontSize + 5);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)buttonWithImage:(UIImage *)image
{
    return [self buttonWithImage:image target:nil selector:nil];
}


+ (UIButton *)naviButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    UIButton *button = [self buttonWithWhiteTitle:title fontSize:16.0f target:target selector:selector];
    return button;
}

+ (UIButton *)navigationButtonForImage:(UIImage *)image target:(id)target selector:(SEL)selector
{
    UIButton *button = [self buttonWithImage:image];
    button.width += 20;
    if (button.height < 30) {
        button.height = 30;
    }
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    if (selector) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

+ (UIButton *)buttonWithBackImage:(UIImage *)image title:(NSString *)title fontSize:(CGFloat)fontSize
{
    return [self buttonWithBackImage:image title:title fontSize:fontSize target:nil selector:nil];
}

+ (UIButton *)buttonWithBackImage:(UIImage *)image title:(NSString *)title fontSize:(CGFloat)fontSize
                           target:(id)target
                         selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (target) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    button.titleLabel.font = font;
    return button;
}

+ (UIButton *)buttonWithImage:(UIImage *)image title:(NSString *)title fontSize:(CGFloat)fontSize
                       target:(id)target
                     selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (target) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    button.titleLabel.font = font;
    return button;
}

+ (UIView *)lineWithPattern:(UIImage *)image width:(CGFloat)width
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, image.size.height)];
    view.backgroundColor = [UIColor colorWithPatternImage:image];
    return view;
}

+ (UIView *)lineWithPattern:(UIImage *)image height:(CGFloat)height
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, height)];
    view.backgroundColor = [UIColor colorWithPatternImage:image];
    return view;
}


/**
 *  通过NIPUIFactoryChild生成常用UILabel控件
 */

+ (UILabel *)labelWithFontSize:(CGFloat)fontSize {
    return [self labelWithText:nil andFontSize:fontSize];
}

+ (UILabel *)labelWithFontSize:(CGFloat)fontSize andTextColor:(UIColor *)textColor {
    return [self labelWithText:nil fontSize:fontSize andTextColor:textColor];
}

+ (UILabel *)labelWithText:(NSString *)text andFontSize:(CGFloat)fontSize {
    return [self labelWithText:text fontSize:fontSize andTextColor:[self blackTextColor]];
}

+ (UILabel *)labelWithText:(NSString *)text fontSize:(CGFloat)fontSize andTextColor:(UIColor *)textColor {
    UIFont *textFont = [UIFont systemFontOfSize:fontSize];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName : textFont}];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.font = textFont;
    textLabel.textColor = textColor;
    return textLabel;
}

+ (UILabel *)labelWithText:(NSString *)text boldFont:(CGFloat)fontsize textColor:(UIColor *)textColor {
    UIFont *textFont = [UIFont boldSystemFontOfSize:fontsize];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName : textFont}];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.font = textFont;
    textLabel.textColor = textColor;
    return textLabel;
}

+ (UILabel *)labelForNavTitle:(NSString *)title
{
    UILabel *naviTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    naviTitleLabel.backgroundColor = [UIColor clearColor];
    naviTitleLabel.font = [UIFont systemFontOfSize:18];
    naviTitleLabel.text = title;
    naviTitleLabel.adjustsFontSizeToFitWidth = YES;
    naviTitleLabel.textColor = [UIColor colorWithHexRGB:0x4e5762];
    return naviTitleLabel;
}


///----------------------------------
/// @name 获取字体
///----------------------------------

+ (UIFont *)fontWithSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)boldFontWithSize:(CGFloat)fontSize {
    return [UIFont boldSystemFontOfSize:fontSize];
}

+ (UIFont *)numberFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Verdana" size:size];
}


///----------------------------------
/// @name 获取 color
///----------------------------------
+ (UIColor *)colorWithHexString:(NSString *)str
{
    if (!NOT_EMPTY_STRING(str) || ![str containsSubstring:@"#"] || str.length != 7) {
        return nil;
    }
    unsigned red, green, blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1];
    return color;
}

+ (UIColor *)grayTitleColor
{
    return [UIColor colorWithRed:240 / 255.0f green:240 / 255.0f blue:240 / 255.0f alpha:1.0];
}

+ (UIColor *)grayContentColor
{
    return [UIColor colorWithRed:248 / 255.0f green:248 / 255.0f blue:248 / 255.0f alpha:1.0];
}

+ (UIColor *)blackTextColor
{
    return [UIColor colorWithRed:51 / 255.0f green:51 / 255.0f blue:51 / 255.0f alpha:1.0];
}

+ (UIColor *)blackTextColor1
{
    return [UIColor colorWithRed:85 / 255.0f green:85 / 255.0f blue:85 / 255.0f alpha:1.0];
}

+ (UIColor *)blackTextColor2
{
    return [UIColor colorWithRed:115 / 255.0f green:115 / 255.0f blue:115 / 255.0f alpha:1.0];
}

+ (UIColor *)orangeTextColor2
{
    return [UIColor colorWithRed:255 / 255.0f green:104 / 255.0f blue:6 / 255.0f alpha:1.0];
}

+ (UIColor *)yellowTextColor
{
    return [UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:140 / 255.0f alpha:1.0];
}

+ (UIColor *)linkTextColor
{
    return [UIColor colorWithRed:58 / 255.0f green:117 / 255.0f blue:197 / 255.0f alpha:1.0];
}

+ (UIColor *)blueTextColor
{
    return [UIColor colorWithRed:58 / 255.0f green:158 / 255.0f blue:226 / 255.0f alpha:1.0];
}

+ (UIColor *)contentViewBackgroundColor{
    return [UIColor colorWithRed:245 / 255.0f green:245 / 255.0f blue:245 / 255.0f alpha:1.0];
}

+ (UIColor *)shadowColorForWhiteText
{
    return [UIColor colorWithRed:0x33 / 255.0f green:0x4d / 255.0f blue:0x14 / 255.0f alpha:0.2f];
}

+ (UIColor *)shadowColorForBlackText
{
    return [UIColor colorWithRed:0xff / 255.0f green:0xff / 255.0f blue:0xff / 255.0f alpha:0.5f];
}

@end
