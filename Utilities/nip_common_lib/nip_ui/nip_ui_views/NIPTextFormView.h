//
//  NIPTextFormView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"
#import "NIPGridLayout.h"

/**
 *  一个文字表格，防html里面的table
 */
@interface NIPTextFormView : NIPGridLayout
@property(nonatomic) UIColor *colum1Color;
@property(nonatomic) UIColor *colum2Color;
@property(nonatomic) UIFont *colum1Font;
@property(nonatomic) UIFont *colum2Font;
@property(nonatomic) CGFloat colum1Width;
@property(nonatomic) CGFloat colum2Width;

- (void)setTextArray:(NSArray*)textArray;
@end
