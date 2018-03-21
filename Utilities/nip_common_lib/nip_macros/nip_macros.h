//
//  nip_macros.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

// APP Info
#pragma mark- APP Info
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_BUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APP_IDENTIFIER [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] componentsSeparatedByString:@"."] lastObject]
#define APP_SCHEME [[[[[[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]] objectForKey:@"CFBundleURLTypes"] firstObject] objectForKey:@"CFBundleURLSchemes"] firstObject]

// 忽略指定的警告
// --忽略PerformSelector警告
#define SUPPRESS_PerformSelectorLeak_WARNING(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

// --忽略未定义方法警告
#define  SUPPRESS_Undeclaredselector_WARNING(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

// --忽略过期API警告
#define SUPPRESS_DEPRECATED_WARNING(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

// Functions
#pragma mark- Functions
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


#define ENCODE_PROPERTY(property,type) if(self.property) {[aCoder encode##type:self.property forKey:@#property];}
#define DECODE_PROPERTY(property,type) self.property = [aDecoder decode##type##ForKey:@#property]


#define CheckAndAlert(condition,message) if(!(condition)) {alertMessage(nil,message);return;}

#define metamacro_concat_(A, B) A ## B

// Device Info
#pragma mark- Device Info
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height


//System Version Judge
#pragma mark- System Version Judge
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//Device Category
#pragma mark- Device Category
#define IS_IPHONE        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6      (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)


//代码块
#pragma mark- 代码块
#define WEAK_SELF(weakSelf) __weak __typeof(self) weakSelf = self;
#define STRONG_SELF(strongSelf) __strong __typeof(weakSelf) strongSelf = weakSelf;

#pragma mark 颜色
#pragma mark use UIColor category

#pragma mark 判空/比较
#define notEmptyString(tempString) ([tempString isKindOfClass:[NSString class]] && tempString.length && !([tempString compare:@"null" options:NSCaseInsensitiveSearch] == NSOrderedSame))
#define EMPTY_STRING_IF_NIL(a) (((a) == nil) ? @"" : (a))
#define IF_A_EMPTY_THEN_B(a, b) ([a isEqualToString:@""] || (a) == nil) ? b : a;

#define notEmptyArray(tempArray) ([tempArray isKindOfClass:[NSArray class]] && tempArray.count > 0)
#define notEmptyDictionary(tempDict) ([tempDict isKindOfClass:[NSDictionary class]] && tempDict.count > 0)

#define notZeroFloat(x) (fabs((double)x) > 1e-6)

#pragma mark Size/Point
#define CGRectGetCenterPoint(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define sizeFix(x) (x*([[UIScreen mainScreen] bounds].size.width)/320.f)


