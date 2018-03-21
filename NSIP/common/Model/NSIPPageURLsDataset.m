//
//  NSIPPageURLsDataset.m
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NSIPPageURLsDataset.h"
#import "NIPConfigFileUpdateService.h"
#import "JSONKit.h"


@interface NSIPPageURLsDataset ()

@property (nonatomic, strong) NSDictionary *pageURlsMap;

@end

@implementation NSIPPageURLsDataset


+ (instancetype)sharedDataset {
    static NSIPPageURLsDataset *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NSIPPageURLsDataset alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:NSIP_CONFIG_NOTIFICATION_KEYWORD
                                                          object:[NIPConfigFileUpdateService sharedService]
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSDictionary *userInfo = [note userInfo];
                                                          NSString *keyWord = userInfo[NSIP_CONFIG_NOTIFICATION_KEYWORD];
                                                          if ([keyWord isEqualToString:PAGE_URL_INFO_KEY]) {
                                                              _pageURlsMap = nil;
                                                          }
                                                      }];

    }
    return self;
}

+ (NSDictionary *)dataset {
    NSIPPageURLsDataset *dataset = [self sharedDataset];
    if (!dataset.pageURlsMap) {
        NSString *filePath = [NIPConfigFileUpdateService sharedService].pageURLsInfoFilePath;
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if ([data bytes]) {
            dataset.pageURlsMap = [data objectFromJSONData];
        }
    }
    return [dataset pageURlsMap];
}

+ (NSArray *)tabURLs {
    NSArray *tabURLs = [[self dataset] objectForKey:@"tabURLS"];
    return tabURLs;
}

+ (NSArray *)commonURLs {
    NSArray *commonURLs = [[self dataset] objectForKey:@"commonURLs"];
    return commonURLs;
}


+ (NSString *)getRoutes:(NSString *)urlString {
    return [NSString stringWithFormat:@""];
}

@end
