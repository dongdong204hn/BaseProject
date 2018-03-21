//
//  UILabel+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "UILabel+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"

@implementation UILabel (NIPAddition_resize)

- (void)resizeOnContentWithConstraint:(CGSize)contraint {
    CGRect textRect = [self textRectForBounds:CGRectMake(0, 0, contraint.width,contraint.height)
                       limitedToNumberOfLines:self.numberOfLines];
    self.size = textRect.size;
}

- (void)resizeHeightOnContent {
    [self resizeHeightOnContentWithConstraint:CGFLOAT_MAX];
}

- (void)resizeHeightOnContentWithConstraint:(CGFloat)heightConstraint {
    CGRect textRect = [self textRectForBounds:CGRectMake(0, 0, self.width, heightConstraint) limitedToNumberOfLines:self.numberOfLines];
    self.height = textRect.size.height;
}


- (void)resizeWidthOnContent {
    [self resizeWidthOnContentWithConstraint:CGFLOAT_MAX];
}

- (void)resizeWidthOnContentWithConstraint:(CGFloat)withConstraint {
    CGRect textRect = [self textRectForBounds:CGRectMake(0, 0, withConstraint, self.height) limitedToNumberOfLines:self.numberOfLines];
    self.width = textRect.size.width;
}

@end
