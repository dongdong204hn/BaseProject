//
//  NIPActivityButton.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPControl.h"

/**
 *  一个UIButton,内含一个ActivityIndicator，当处于活动状态时(inActivity==YES)，button不可点，显示ActivityIndicator
 */
@interface NIPActivityButton : NIPControl
@property(nonatomic,readonly) UIButton *button;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *titleInActivity;
@property(nonatomic) BOOL inActivity;
@end
