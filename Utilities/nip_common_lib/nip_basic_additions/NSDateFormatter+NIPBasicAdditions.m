//
//  NSDateFormatter+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/30.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NSDateFormatter+NIPBasicAdditions.h"

@implementation NSDateFormatter (NIPBasicAdditions)

+ (NSDateFormatter *)defaultDateTimeFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return formater;
}

+ (NSDateFormatter *)dateTimeNoSecondFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return formater;
}

+ (NSDateFormatter *)chineseDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"yyyy年MM月dd日"];
    }
    return formater;
}

+ (NSDateFormatter *)chineseMonthDayDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"MM月dd日"];
    }
    return formater;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"yyyy-MM-dd"];
    }
    return formater;
}

+ (NSDateFormatter *)shortTimeFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"HH:mm"];
    }
    return formater;
}

+ (NSDateFormatter *)shortDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"MM.dd"];
    }
    return formater;
}

+ (NSDateFormatter *)shortDateFormatterHorizon {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"MM-dd"];
    }
    return formater;
}

+ (NSDateFormatter *)compactShortDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"MMdd"];
    }
    return formater;
}

+ (NSDateFormatter *)shortFullDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"yyyy.MM.dd"];
    }
    return formater;
}

+ (NSDateFormatter *)compactFullDateFormatter {
    static NSDateFormatter *formater = nil;
    if (!formater) {
        formater =[[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];
        [formater setDateFormat:@"yyyyMMdd"];
    }
    return formater;
}

@end
