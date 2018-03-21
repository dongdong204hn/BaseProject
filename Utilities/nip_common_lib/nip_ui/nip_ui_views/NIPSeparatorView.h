//
//  NIPSeparatorView.h
//  NSIP
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIPSeparatorView : UIView

+ (CGFloat)height;
+ (NIPSeparatorView *)separatorView;
+ (NIPSeparatorView *)separatorOfHeight:(CGFloat)height;
+ (NIPSeparatorView *)dashSeparatorOfHeight:(CGFloat)height;
+ (NIPSeparatorView *)verticalSeparatorOfHeight:(CGFloat)height;
+ (NIPSeparatorView *)separatorOfHeight:(CGFloat)height horizentalInset:(CGFloat)inset;

@end
