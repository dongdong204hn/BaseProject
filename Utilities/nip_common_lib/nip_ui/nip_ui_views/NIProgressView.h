//
//  NIProgressView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  一个自定义进度条
 */
@interface NIProgressView : NIPView {
    float _progress;
    UIColor *_progressColor;
    UIColor *_progressEndColor;
    UIColor *_progressBackColor;
    UIColor *_progressBorderColor;
}
@property(nonatomic) float progress;
@property(nonatomic,strong) UIColor *progressColor;
@property(nonatomic,strong) UIColor *progressEndColor;
@property(nonatomic,strong) UIColor *progressBackColor;
@property(nonatomic,strong) UIColor *progressBorderColor;
@end
