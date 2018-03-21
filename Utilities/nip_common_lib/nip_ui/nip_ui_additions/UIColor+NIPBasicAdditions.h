//
//  UIColor+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  UIColor NTUIAddtion
 */
@interface UIColor (NIPBasicAddtions)
/// 获取用于view的有渐变色的layer
+ (CAGradientLayer *)gradientLayerByView:(UIView *)view fromColor:(NSUInteger)fromHexColor toColor:(NSUInteger)toHexColor;

/**
 * Accepted ranges:
 *        hue: 0.0 - 360.0
 * saturation: 0.0 - 1.0
 *      value: 0.0 - 1.0
 *      alpha: 0.0 - 1.0
 */
+ (UIColor*)colorWithHue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v alpha:(CGFloat)a;

+ (UIColor *)colorWithHexRGBA:(NSUInteger)rgba;
+ (UIColor *)colorWithHexRGB:(NSUInteger)rgb;

+ (UIColor *)colorWithIntegerR:(NSUInteger)r g:(NSUInteger)r b:(NSUInteger)b a:(CGFloat)a;

/**
 * Accepted ranges:
 *        hue: 0.0 - 1.0
 * saturation: 0.0 - 1.0
 *      value: 0.0 - 1.0
 */
- (UIColor*)multiplyHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

- (UIColor*)addHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

/**
 * Returns a new UIColor with the given alpha.
 */
- (UIColor*)copyWithAlpha:(CGFloat)newAlpha;

/**
 * Uses multiplyHue:saturation:value:alpha: to create a lighter version of the color.
 */
- (UIColor*)highlight;

/**
 * Uses multiplyHue:saturation:value:alpha: to create a darker version of the color.
 */
- (UIColor*)shadow;

- (CGFloat)hue;

- (CGFloat)saturation;

- (CGFloat)value;


/**
 * Get RGBA information
 */
- (CGFloat)redChannel;

- (CGFloat)greenChannel;

- (CGFloat)blueChannel;

- (CGFloat)alphaChannel;

@end
