//
//  NIPointIndicator.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  一个类似appstore打星级的控件
 */
@interface NIPointIndicator: NIPView

@property(nonatomic) NSInteger pointCount;
@property(nonatomic) CGFloat progress;
@property(nonatomic) CGFloat pointSpace;
@property(nonatomic) BOOL progressModel;

-(void)setPointImage:(UIImage*)image andBackImage:(UIImage*)backImage;

@end