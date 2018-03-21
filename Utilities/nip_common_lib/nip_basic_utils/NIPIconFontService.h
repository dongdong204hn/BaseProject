//
//  NIPIconFontService.h
//  Exchange
//
//  Created by Eric on 2017/5/24.Modified by zhaosong on 2017/12/6.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPIconFontService : NSObject

/** 注册多个字体文件 names: eg @[@"nsip"] */
+ (void)registerIconFontsByNames:(NSArray *)names;
+ (void)registerIconFontWithFilePath:(NSString *)filePath;
+ (void)copyFontToLocalWithName:(NSString *)fontName;

@end
