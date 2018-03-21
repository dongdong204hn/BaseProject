//
//  NIPTimePicker.h
//  trainTicket
//
//  Created by 赵松 on 15/5/22.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "NIPCustomAlertBase.h"

/**
 *  选择整点区间
 */
@interface NIPTimePicker : NIPCustomAlertBase

@property(nonatomic) NSString *dateStart;
@property(nonatomic) NSString *dateEnd;

+ (instancetype)timePickerWithTitle:(NSString *)title;

@end
