//
//  NIPGridLayout.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPLayoutBase.h"

/**
 *  NIPGridLayout是表格式layout
 */
@interface NIPGridLayout : NIPLayoutBase
@property(nonatomic) NSInteger columnCount;
@property(nonatomic) CGFloat rowSpace;
@property(nonatomic) CGFloat columnSpace;
@end
