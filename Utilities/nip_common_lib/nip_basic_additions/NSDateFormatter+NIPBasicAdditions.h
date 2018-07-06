//
//  NSDateFormatter+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/30.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (NIPBasicAdditions)

/// yyyy-MM-dd HH:mm:ss
+ (NSDateFormatter *)defaultDateTimeFormatter;

/// yyyy-MM-dd HH:mm
+ (NSDateFormatter *)dateTimeNoSecondFormatter;

/// yyyy年MM月dd日
+ (NSDateFormatter *)chineseDateFormatter;

/// MM月dd日
+ (NSDateFormatter *)chineseMonthDayDateFormatter;

/// yyyy-MM-dd
+ (NSDateFormatter *)defaultDateFormatter;

/// HH:mm
+ (NSDateFormatter *)shortTimeFormatter;

/// MM.dd
+ (NSDateFormatter *)shortDateFormatter;

/// MM-dd
+ (NSDateFormatter *)shortDateFormatterHorizon;

/// MMdd
+ (NSDateFormatter *)compactShortDateFormatter;

/// yyyy.MM.dd
+ (NSDateFormatter *)shortFullDateFormatter;

/// yyyy.MM.dd
+ (NSDateFormatter *)compactFullDateFormatter;

@end
