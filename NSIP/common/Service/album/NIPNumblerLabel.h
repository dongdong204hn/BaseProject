//
//  NIPNumblerLabel.h
//  NSIP
//
//  Created by Eric on 2016/12/19.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIPNumblerLabel : UIView

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *backgroundViewColor;

+ (NIPNumblerLabel *)numberLableWithTitleColor:(UIColor *)titleColor andBackgroundColor:(UIColor *)backgroundColor;

- (void)setNumber:(NSInteger)number animated:(BOOL)animated;

@end
