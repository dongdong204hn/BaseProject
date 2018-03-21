//
//  NSIPPageURLsDataset.h
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIPPageURLsDataset : NSObject

+ (NSString *)getRoutes:(NSString *)urlString;

+ (NSArray *)tabURLs;

+ (NSArray *)commonURLs;

@end
