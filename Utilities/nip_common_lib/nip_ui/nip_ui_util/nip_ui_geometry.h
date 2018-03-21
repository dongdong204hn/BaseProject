//
//  nip_ui_geometry.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CC_SWAP(x, y, type)    \
{    type temp = (x);        \
x = y; y = temp;        \
}

float clampf(float value, float min_inclusive, float max_inclusive);
int clamp(int value, int min_inclusive, int max_inclusive);
CG_INLINE CGPoint CGPointMultiply(CGPoint point1,CGPoint point2);
CG_INLINE CGPoint CGPointAdd(CGPoint point1,CGPoint point2);

#pragma mark - 
#pragma mark path create
//创建圆角矩形
CGPathRef CGPathCreateRoundrect(CGRect rect, CGFloat radius);
//创建扇形
CGPathRef CGPathCreateFan(CGPoint center, CGFloat radius, CGFloat angle1, CGFloat angle2);


#pragma mark - 
#pragma mark rect 
CGRect CGRectCenterRect(CGRect outerRect,CGSize size);
CGPoint CGRectCenterPoint2(CGRect rect);
CGRect CGRectInnerRectWithInset(CGRect rect, UIEdgeInsets insets);

//definitions of inline
CG_INLINE CGPoint CGPointMultiply(CGPoint point1,CGPoint point2) {
    return CGPointMake(point1.x*point2.x, point1.y*point2.y);
}

CG_INLINE CGPoint CGPointAdd(CGPoint point1,CGPoint point2) {
    return CGPointMake(point1.x+point2.x, point1.y+point2.y);
}