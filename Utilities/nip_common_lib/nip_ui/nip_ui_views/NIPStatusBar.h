//
//  NIPStatusBar.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  自定义StatusBar
 */
@interface NIPStatusBar : UIWindow

@property(nonatomic,strong) UIView *contentView;

+ (NIPStatusBar*)bar;
- (void)destroy;

@end
