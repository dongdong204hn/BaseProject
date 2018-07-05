//
//  NSDate+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

#import "NSDate+NIPBasicAdditions.h"
#import "NSDateFormatter+NIPBasicAdditions.h"
#import "nip_macros.h"

@implementation NSDate (NIPBasicAdditions)

- (NSInteger) nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
    return components.hour;
}

- (NSInteger) hour
{
    return [self dateComponents].hour;
}

- (NSInteger) minute
{
    return [self dateComponents].minute;
}

- (NSInteger) seconds
{
    return [self dateComponents].second;
}

- (NSInteger) day
{
    return [self dateComponents].day;
}

- (NSInteger) month
{
    return [self dateComponents].month;
}

- (NSInteger) week
{
    return [self dateComponents].week;
}

- (NSInteger) weekday
{
    return [self dateComponents].weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    return [self dateComponents].weekdayOrdinal;
}

- (NSInteger) year
{
    return [self dateComponents].year;
}

- (NSDateComponents *)dateComponents
{
    NSDateComponents * components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    //components.timeZone = [NSTimeZone localTimeZone];
    return components;
}

+ (NSDate *)dateWithString:(NSString *)string dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter dateFromString:string];
}

- (NSDate *)trimDateOffTime {
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    return [gregorian dateFromComponents:[gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self]];
}

+ (NSDate *) dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateTheDayBeforeYesterday
{
    return [NSDate dateWithDaysBeforeNow:2];
}

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //[calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}

- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (BOOL)isSameDayWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    NSDateComponents *selfComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
    return (dateComponents.year == selfComponents.year) && (dateComponents.month == selfComponents.month) && (dateComponents.day == selfComponents.day);
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)pekingDateStringWithDateFormat:(NSString *)dateFormat
{
    static NSDateFormatter *pekingDateFormatter = nil;
    if (!pekingDateFormatter) {
        pekingDateFormatter = [[NSDateFormatter alloc] init];
        [pekingDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
        [pekingDateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [pekingDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh"]];
    }
    [pekingDateFormatter setDateFormat:dateFormat];
    return [pekingDateFormatter stringFromDate:self];
}

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date {
    return !([self compare:date] == NSOrderedAscending);
}

-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date {
    return !([self compare:date] == NSOrderedDescending);
}

-(BOOL) isLaterThan:(NSDate*)date {
    return ([self compare:date] == NSOrderedDescending);
    
}

-(BOOL) isEarlierThan:(NSDate*)date {
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL) isToday
{
    return [self isSameDayWithDate:[NSDate date]];
}

- (BOOL) isTomorrow
{
    return [self isSameDayWithDate:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
    return [self isSameDayWithDate:[NSDate dateYesterday]];
}

- (BOOL) isTheDayBeforeYesterday
{
    return [self isSameDayWithDate:[NSDate dateTheDayBeforeYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.week != components2.week) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
    
    return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
    
    return (components1.year == (components2.year - 1));
}

- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

- (NSString *)chnDescByFlag:(NSInteger)flag {
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDate *today= [gregorian dateFromComponents:[gregorian components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]]];
    
    NSDateComponents *componentDif = [gregorian components:NSDayCalendarUnit fromDate:today toDate:self options:0];
    if (1 == flag) {
        switch (componentDif.day) {
            case 0:
                return @"今天";
                break;
                
            case 1:
                return @"明天";
                break;
                
            case 2:
                return @"后天";
                break;
                
            case 3:
                return @"大后天";
                break;
                
            default:
                break;
        }
    } else if (2 == flag) {
        switch (componentDif.day) {
            case 0:
                return @"当天";
                break;
                
            case 1:
                return @"次日";
                break;
                
            case 2:
                return @"第三日";
                break;
                
            case 3:
                return @"第四日";
                break;
                
            default:
                break;
        }
    }
    return nil;
}

- (NSInteger)dayIntervalToDate:(NSDate *)toDate {
    if (!toDate) {
        return NSIntegerMax;
    }
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDate *zeroDate = [NSDate dateWithString:[NSString stringWithFormat:@"%@ 00:00", [[NSDateFormatter defaultDateFormatter] stringFromDate:self]] dateFormat:[NSString stringWithFormat:@"%@ HH:mm", [[NSDateFormatter defaultDateFormatter] dateFormat]]];
    NSDateComponents *componentDif = [gregorian components:NSDayCalendarUnit fromDate:zeroDate toDate:toDate options:0];
    return [componentDif day];
}

- (NSInteger)weekdayIndex {
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:self];
    return (components.weekday == 1? 7: components.weekday - 1);
}

- (NSString *)weekdayChn {
    NSInteger weekDay = [self weekdayIndex];
    switch (weekDay) {
        case 1:
            return @"一";
            break;
            
        case 2:
            return @"二";
            break;
            
        case 3:
            return @"三";
            break;
            
        case 4:
            return @"四";
            break;
            
        case 5:
            return @"五";
            break;
            
        case 6:
            return @"六";
            break;
            
        case 7:
            return @"日";
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSString *)festivalName {
    NSString *festivalName = nil;
    
    NSCalendar *chinaCalendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    NSInteger desiredComponents= NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *chinaDateComponents= [chinaCalendar components:desiredComponents fromDate:self];
    // 公历
    NSCalendar *calendar= [NSCalendar currentCalendar];
    NSDateComponents *dateComponents= [calendar components:desiredComponents fromDate:self];
    // 优先查询农历节日
    NSString *temp = [self festivalNameByDateComponents:chinaDateComponents andChineseFlag:YES];
    if (NOT_EMPTY_STRING(temp)) {
        festivalName = temp;
    } else {
        // 查询公历节日
        temp = [self festivalNameByDateComponents:dateComponents andChineseFlag:NO];
        if (NOT_EMPTY_STRING(temp)) {
            festivalName = temp;
        } else {
            // 判断是否“除夕”
            if (chinaDateComponents.month == 12) { //除夕要通过下一天是否是春节来判断
                NSDate *tempDate = [NSDate dateWithTimeInterval:60*60*24 sinceDate:self];
                NSDateComponents *tempDateComponents = [chinaCalendar components:desiredComponents fromDate:tempDate];
                if ([@"春节" isEqualToString:[self festivalNameByDateComponents:tempDateComponents andChineseFlag:YES]]) {
                    festivalName = @"除夕";
                }
            }
        }
    }
    if (!NOT_EMPTY_STRING(festivalName)) {
        if (chinaDateComponents.day == 1) {
            // 每月初一，显示农历月份
            festivalName = [self chineseMonthNameByMonthIndex:chinaDateComponents.month];
            if (chinaDateComponents.isLeapMonth) {
                // 处理闰月
                festivalName = [NSString stringWithFormat:@"闰%@", festivalName];
            }
        } else {
            // 查询农历日期
            festivalName = [self chineseDayNameByDayIndex:chinaDateComponents.day];
        }
    }
    
    return festivalName;
}

- (NSString *)festivalNameByDateComponents:(NSDateComponents *)dateComponents andChineseFlag:(BOOL)chineseFlag {
    NSMutableDictionary *holiday;
    if (chineseFlag) {
        holiday = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   @"春节", @"1-1",
                   @"元宵", @"1-15",
                   @"端午", @"5-5",
                   @"中秋", @"8-15",
                   @"小年", @"12-23",
                   nil];
    } else {
        holiday = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   @"元旦", @"1-1",
                   @"劳动", @"5-1",
                   @"国庆", @"10-1",
                   nil];
        // 清明的日期是不固定的
        NSInteger year = dateComponents.year % 2000;
        NSInteger factory_1 = (NSInteger)(year * 0.2422 + 4.81);
        NSInteger factory_2 = year / 4;
        NSInteger day = factory_1 - factory_2;
        NSString *key = [NSString stringWithFormat:@"4-%ld",(long)day];
        [holiday setValue:@"清明" forKey:key];
    }
    NSString *keyStr = [NSString stringWithFormat:@"%ld-%ld", (long)dateComponents.month, (long)dateComponents.day];
    return [holiday objectForKey:keyStr];
}

- (NSString *)chineseMonthNameByMonthIndex:(NSInteger)monthIndex {
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月", nil];
    if (monthIndex > 0 && monthIndex < 13) {
        return chineseMonths[monthIndex - 1];
    }
    return nil;
}

- (NSString *)chineseDayNameByDayIndex:(NSInteger)dayIndex {
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    if (chineseDays.count > dayIndex - 1 && dayIndex > 0) {
        return chineseDays[dayIndex - 1];
    }
    return nil;
}

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

- (NSInteger)ageFromBirthday {
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDate *zeroDate = [NSDate dateWithString:[NSString stringWithFormat:@"%@ 00:00", [[NSDateFormatter defaultDateFormatter] stringFromDate:self]] dateFormat:[NSString stringWithFormat:@"%@ HH:mm", [[NSDateFormatter defaultDateFormatter] dateFormat]]];
    NSDateComponents *componentDif = [gregorian components:NSYearCalendarUnit fromDate:zeroDate toDate:[NSDate date] options:0];
    if (componentDif) {
        return [componentDif year];
    }
    return -1;
}


@end
