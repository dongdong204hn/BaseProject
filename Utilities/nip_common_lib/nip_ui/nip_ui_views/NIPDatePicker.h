//
//  NIPDatePicker.h
//  trainTicket
//
//  Created by 赵松 on 15/5/22.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "NIPCustomAlertBase.h"

@interface NIPDatePicker : NIPCustomAlertBase

@property(nonatomic) NSDate *date;

+ (instancetype)datePickerWithTitle:(NSString *)title;

@end
