//
//  NIPLayoutLabel.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  一个可以支持段落布局的label
 */
@interface NIPLayoutLabel : UILabel
@property(nonatomic,assign) CGFloat characterSpacing;
@property(nonatomic,assign)  CGFloat linesSpacing;
@property(nonatomic) CGFloat paragraphSpacing;
@property(nonatomic) CGFloat paragraphIndentSpacing;
- (CGSize)sizeThatFits:(CGSize)size;
@end
