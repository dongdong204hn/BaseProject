// UIImage+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

/**
 *  UIImage NTUIAddtion_Create
 */
@interface UIImage(NIPAddtion_Create)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end

/**
 *  UIImage NTUIAddtion_Alpha
 */
@interface UIImage (NIPAddtion_Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)imageWithAlpha:(CGFloat)alpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (UIImage *)imageWithShadow:(UIColor*)_shadowColor 
				 shadowSize:(CGSize)_shadowSize
					   blur:(CGFloat)_blur;

- (UIImage *)maskWithColor:(UIColor *)color;

- (UIImage *)maskWithColor:(UIColor *)color 
			   shadowColor:(UIColor *)shadowColor
			  shadowOffset:(CGSize)shadowOffset
				shadowBlur:(CGFloat)shadowBlur;
@end

/**
 *  UIImage NTUIAddtion_Resize
 */
@interface UIImage (NIPAddtion_Resize)
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

-(UIImage*)rotate:(UIImageOrientation)orient;
-(UIImage*)resizeImageWithNewSize:(CGSize)newSize;
@end

/**
 *  UIImage NTUIAddtion_RoundedCorner
 */
@interface UIImage (NIPAddtion_RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (UIImage*)imageWithRadius:(float) radius 
					  width:(float)width
					 height:(float)height;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end

@interface UIImage (NIPAddtion_Color)

- (UIColor *)mostColor;

@end
