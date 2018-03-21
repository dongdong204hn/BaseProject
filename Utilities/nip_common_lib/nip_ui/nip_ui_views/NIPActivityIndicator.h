//
//  NIPActivityIndicator.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  自定义ActivityIndicator
 */
@interface NIPActivityIndicator : NIPView

@property(nonatomic,strong) UIImage *indicatorImage;
@property(nonatomic,strong) NSArray *indicatorImages;

//与系统ActivityIndicatorView方法名保持一致
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
@end
