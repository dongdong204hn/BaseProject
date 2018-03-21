//
//  NIPreciousLocalSettings.m
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPreciousLocalSettings.h"

@implementation NIPreciousLocalSettings

+ (instancetype)settings {
    static NIPreciousLocalSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NIPreciousLocalSettings alloc] init];
    });
    return sharedInstance;
}

NIP_SETTER_GETTER_BOOL(hasGlobalTextPath, HasGlobalTextPath);
NIP_SETTER_GETTER_BOOL(hasPromptTextPath, HasPromptTextPath);
NIP_SETTER_GETTER_BOOL(hasPageURLsInfoPath, HasPageURLsInfoPath);


@end
