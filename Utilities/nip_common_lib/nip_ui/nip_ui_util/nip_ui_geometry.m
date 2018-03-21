//
//  nip_ui_geometry.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "nip_ui_geometry.h"

float clampf(float value, float min_inclusive, float max_inclusive)
{
    if (min_inclusive > max_inclusive) {
        CC_SWAP(min_inclusive, max_inclusive, float);
    }
    return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
}

int clamp(int value, int min_inclusive, int max_inclusive) {
    if (min_inclusive > max_inclusive) {
        CC_SWAP(min_inclusive, max_inclusive, float);
    }
    return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
}


CGPathRef CGPathCreateRoundrect(CGRect rect, CGFloat radius)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL,CGRectGetMinX(rect), CGRectGetMinY(rect)+radius);
    CGPathAddArcToPoint(path,NULL,CGRectGetMinX(rect),CGRectGetMinY(rect), CGRectGetMaxX(rect)-radius, CGRectGetMinY(rect),radius);
    CGPathAddArcToPoint(path,NULL,CGRectGetMaxX(rect), CGRectGetMinY(rect),CGRectGetMaxX(rect), CGRectGetMaxY(rect)-radius,radius);
    CGPathAddArcToPoint(path,NULL,CGRectGetMaxX(rect), CGRectGetMaxY(rect),CGRectGetMinX(rect)+radius, CGRectGetMaxY(rect),radius);
    CGPathAddArcToPoint(path,NULL,CGRectGetMinX(rect), CGRectGetMaxY(rect),CGRectGetMinX(rect), CGRectGetMinY(rect)+radius,radius);
    CGPathCloseSubpath(path);
    return path;
}

CGPathRef CGPathCreateFan(CGPoint center, CGFloat radius, CGFloat angle1, CGFloat angle2)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    CGPoint point1 = CGPointMake(center.x+radius*cos(angle1),center.y + radius*sin(angle1));
    CGPathAddLineToPoint(path, NULL, point1.x, point1.y);
    CGPathAddArc(path,NULL,center.x, center.y, radius, angle1, angle2,0);
    CGPathAddLineToPoint(path,NULL,center.x, center.y);
    CGPathCloseSubpath(path);
    return path;
}

CGRect CGRectCenterRect(CGRect outerRect,CGSize size) {
    return CGRectMake(outerRect.origin.x+(outerRect.size.width-size.width)/2,
                      outerRect.origin.y+(outerRect.size.height-size.height)/2,
                      size.width,
                      size.height);
}

CGPoint CGRectCenterPoint2(CGRect rect) {
    return CGPointMake(rect.origin.x+rect.size.width/2,rect.origin.y+rect.size.height/2);
}

CGRect CGRectInnerRectWithInset(CGRect rect, UIEdgeInsets insets) {
    return CGRectMake(rect.origin.x+insets.left,
                      rect.origin.y+insets.top,
                      rect.size.width-insets.left-insets.right,
                      rect.size.height-insets.top-insets.bottom);
}
