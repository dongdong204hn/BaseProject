//
//  NIPLabelView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  是一个仿label的view，可以设置背景色，并且增加edgeInsets功能
 */
@interface NIPLabelView : NIPView

@property(nonatomic,strong) NSString *text;
@property(nonatomic,readonly) UILabel *label;
@property(nonatomic,assign) UIEdgeInsets edgeInsets;

- (void)resizeHeightOnContent;

@end
