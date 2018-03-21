//
//  NIPIconTextView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  一个图标+文字的view
 */
@interface NIPIconTextView : NIPView

@property(nonatomic,readonly) UIImageView *iconView;
@property(nonatomic,readonly) UILabel *textLabel;
@property(nonatomic) NSTextAlignment alignment;
@property(nonatomic) UIEdgeInsets edgeInserts;
@property(nonatomic) CGFloat iconTextSpace;
@property(nonatomic) BOOL textFirst;
@property(nonatomic) BOOL verticalLayout;

@property(nonatomic,strong) UIImage *icon;
@property(nonatomic,strong) id text; //NSString or NSAttributeString
@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;

@end
