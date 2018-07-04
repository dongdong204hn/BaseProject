//
//  nip_macros.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark- APP Info
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_BUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APP_IDENTIFIER [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] componentsSeparatedByString:@"."] lastObject]
#define APP_SCHEME [[[[[[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]] objectForKey:@"CFBundleURLTypes"] firstObject] objectForKey:@"CFBundleURLSchemes"] firstObject]

#pragma mark - 忽略指定的警告
#pragma mark 忽略PerformSelector警告
#define IGNORE_PERFORMSELECTORLEAK_WARNING(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#pragma mark 忽略未定义方法警告
#define IGNORE_UNDECLAREDSELECTOR_WARNING(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#pragma mark 忽略过期API警告
#define IGNORE_DEPRECATED_WARNING(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#pragma mark - Device Info
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#pragma mark - 设备信息
#pragma mark 区分屏幕尺寸。TIP：只用于区分屏幕尺寸，具体版本信息获取参加UIDevice+NIPBasicAdditions.h
#define IS_IPHONE        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

#pragma mark System Version Judge
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - 方法和代码块
#pragma mark LOG
#if DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#  define LOG_OBJ(obj) NSLog(@"%@",obj)
#  define LOG_RECT(r) NSLog(@"(%.1fx%.1f)-(%.1fx%.1f)", r.origin.x, r.origin.y, r.size.width, r.size.height)
#  define __FUNC_NAME__ NSLog(NSStringFromSelector(_cmd));
#else
#  define LOG(...) ;
#  define LOG_OBJ(obj) ;
#  define LOG_RECT(r) ;
#  define __FUNC_NAME__ ;
#endif

#ifdef DEBUG
#define LOG_DEALLOC  -(void)dealloc {LOG(@"%@:%@",NSStringFromClass(self.class),NSStringFromSelector(_cmd));}
#else
#define LOG_DEALLOC
#endif

#pragma mark 时间间隔
#define NIP_TIME_BEGIN NSDate *startTime = [NSDate date]
#define NIP_TIME_END NSLog(@"时间间隔: %f", -[startTime timeIntervalSinceNow])

#pragma mark alert
#define CHECK_AND_ALERT(condition,message) if(!(condition)) {alertMessage(nil,message);return;}

#pragma mark weakSelf strongSelf
#define WEAK_SELF(weakSelf) __weak __typeof(self) weakSelf = self;
#define STRONG_SELF(strongSelf) __strong __typeof(weakSelf) strongSelf = weakSelf;

#pragma mark 判空/比较
#pragma mark 字符串
#define NOT_EMPTY_STRING(tempString) ([tempString isKindOfClass:[NSString class]] && tempString.length && !([tempString compare:@"null" options:NSCaseInsensitiveSearch] == NSOrderedSame))
#define EMPTY_STRING_IF_NIL(a) (((a) == nil) ? @"" : (a))
#define IF_A_EMPTY_THEN_B(a, b) ([a isEqualToString:@""] || (a) == nil) ? b : a;

#pragma mark 数组
#define NOT_EMPTY_ARRAY(tempArray) ([tempArray isKindOfClass:[NSArray class]] && tempArray.count > 0)

#pragma mark 字典
#define NOT_EMPTY_DICTIONARY(tempDict) ([tempDict isKindOfClass:[NSDictionary class]] && tempDict.count > 0)

#pragma mark 浮点数
#define NOT_ZERO_FLOAT(x) (fabs((double)x) > 1e-6)

#pragma mark SIZE
#define CENTER_POINT_OF_RECT(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define LENGTH_RELATIVE_667(x) (x*([[UIScreen mainScreen] bounds].size.width)/667.f)

