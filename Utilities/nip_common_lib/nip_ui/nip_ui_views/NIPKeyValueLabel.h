//
//  NIPKeyValueLabel.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"
#import "nip_ui_layout.h"

/**
 *  一个名值对的label
 */
@interface NIPKeyValueLabel : NIPView

@property(nonatomic) CGFloat staticKeyPartWidth;
@property(nonatomic) CGFloat staticKeyPartHeight;

@property(nonatomic,strong,readonly) UILabel *keyLabel;
@property(nonatomic,strong,readonly) UILabel *valueLabel;
@property(nonatomic,strong,readonly) NIPLayoutBase *layout;


//sugar interface
@property(nonatomic) NSString *keyText;
@property(nonatomic) NSString *valueText;

- (id)initWithFrame:(CGRect)frame layoutType:(ZBLayoutType)layoutType;
- (void)swapKeyValuePosition;
@end
