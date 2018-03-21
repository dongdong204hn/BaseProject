//
//  NIPDefine.h
//  NSIP
//
//  Created by Eric on 16/9/22.
//  Copyright © 2016年 Eric. All rights reserved.
//

#ifndef NSIPDefine_h
#define NSIPDefine_h

#if DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#endif

// 常量定义
#pragma mark- 常量定义
#pragma mark 页面跳转路径前缀
#define NSIP_PREFIX @"nsip://"

#pragma mark 通知
#define kCOOKIE_CHANGED @"COOKIECHANGED"


// applink前缀
#pragma mark- applink前缀
#define NSIP_APPLINK_PREFIX_1  @"https://app.lmlc.com/lmlc/appcmd/" //applink用
#define NSIP_APPLINK_PREFIX_2  @"https://www.lmlc.com/lmlc/appcmd/" //applink用
#define NSIP_APPLINK_PREFIX_3  @"cf163://www.lmlc.com/" //cf163://www.lmlc.com/mainIndex 这种类型也要支持

// 网络请求相关的宏定义
#define APIVERSION @"v1.0"
#define OS_TYPE @"iPhone"
#define HOST @"https://fa.163.com/interfaces/"


#endif /* NSIPDefine_h */
