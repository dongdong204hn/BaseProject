//
//  NIPIconFontService.m
//  Exchange
//
//  Created by Eric on 2017/5/24. Modified by zhaosong on 2017/12/6. 
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPIconFontService.h"
#import "NIPFileService.h"
#import <CoreText/CoreText.h>

@implementation NIPIconFontService

+ (void)registerIconFontsByNames:(NSArray *)names {
    NSString *document = [NIPFileService documentDirectory];
    NSArray *files = [NIPFileService fileNameListOfType:@"ttf" fromDirPath:document];
    NSString *filePath = nil;
    for (NSString *file in files) {
        filePath = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.ttf", file]];
        [NIPIconFontService registerIconFontWithFilePath:filePath];
    }
    if (!filePath) {
        NSString *wholeName = nil;
        for (NSString *name in names) {
            wholeName = [NSString stringWithFormat:@"%@.ttf", name];
            filePath = [document stringByAppendingPathComponent:wholeName];
            [self copyFontToLocalWithName:name];
            [NIPIconFontService registerIconFontWithFilePath:filePath];
        }
    }
}

+ (void)registerIconFontWithFilePath:(NSString *)filePath {
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:filePath], @"Font file doesn't exist");
    NSData *fontData = [NSData dataWithContentsOfFile:filePath];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontData);
    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(newFont, nil);
    CGFontRelease(newFont);
}

+ (void)copyFontToLocalWithName:(NSString *)fontName {
    NSString *document = [NIPFileService documentDirectory];
    NSString *realPath =  [document stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.ttf", fontName]];
    [NIPFileService copyFile:[NIPFileService bundleFile:fontName withType:@"ttf"] toPath:realPath];
}

@end
