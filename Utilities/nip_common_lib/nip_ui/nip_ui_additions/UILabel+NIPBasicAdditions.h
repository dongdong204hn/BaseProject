//
//  UILabel+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// NIPAddition_resize
@interface UILabel (NIPAddition_resize)
- (void)resizeOnContentWithConstraint:(CGSize)constraint;
- (void)resizeHeightOnContent;
- (void)resizeHeightOnContentWithConstraint:(CGFloat)heightConstraint;
- (void)resizeWidthOnContent;
- (void)resizeWidthOnContentWithConstraint:(CGFloat)withConstraint;
@end
