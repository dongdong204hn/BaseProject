//
//  NSDate+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  NSDate NTBasicAdditions
 */
@interface NSDate (NIPBasicAdditions)

@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

#pragma mark - 获取特定date
/**
 *  将string按照给定的日期格式转化成NSDate对象.
 *
 *  @param string 要转化成NSDate的字符串.
 *
 *  @param dateFormat string的日期格式.
 *
 *  @return 若string和格式与dateFormat相符, 返回对应NSDate对象; 若string格式与dateFormat不符, 返回nil.
 */
+ (NSDate *)dateWithString:(NSString *)string dateFormat:(NSString *)dateFormat;

/// 从完整的时间中提取出日期
- (NSDate *)trimDateOffTime;

+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateTheDayBeforeYesterday;
+ (NSDate *)dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *)dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *)dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *)dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *)dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow: (NSInteger) dMinutes;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateAtStartOfDay;

#pragma - mark - date compare
/// 判断与给定日期是否是同一天.
- (BOOL)isSameDayWithDate:(NSDate *)date;
- (BOOL)isLaterThanOrEqualTo:(NSDate*)date;
- (BOOL)isEarlierThanOrEqualTo:(NSDate*)date;
- (BOOL)isLaterThan:(NSDate*)date;
- (BOOL)isEarlierThan:(NSDate*)date;

- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;
- (BOOL)isTheDayBeforeYesterday;
- (BOOL)isSameWeekAsDate: (NSDate *) aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;
- (BOOL)isSameMonthAsDate: (NSDate *) aDate;
- (BOOL)isThisMonth;
- (BOOL)isSameYearAsDate: (NSDate *) aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;

/// 是否工作日
- (BOOL) isTypicallyWorkday;
/// 是否周末
- (BOOL) isTypicallyWeekend;

#pragma mark - date utils
/// 转化成具有给定日期格式的字符串.
- (NSString *)stringWithDateFormat:(NSString *)dateFormat;
//！ 获取北京时间给定日期格式的字符串。
- (NSString *)pekingDateStringWithDateFormat:(NSString *)dateFormat;

/// 根据flag返回当前日期对应的中文。 flag 1:今天、明天、后天 2:当日、次日、第三日、第四日
- (NSString *)chnDescByFlag:(NSInteger)flag;

/// 返回当前是星期几，中文:一~七
- (NSString *)weekdayChn;

/// 获取对应的节日名
- (NSString *)festivalName;

/// 与toDate之间间隔的天数
- (NSInteger)dayIntervalToDate:(NSDate *)toDate;

/// 返回当前是星期几，数字形式:1~7
- (NSInteger)weekdayIndex;

- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
- (NSInteger) distanceInDaysToDate:(NSDate *)anotherDate;

/// 从身份证号码中提取年龄
- (NSInteger)ageFromBirthday;

@end
