//
//  NIPreciousLocalSettings.h
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPLocalSettings.h"

@interface NIPreciousLocalSettings : NIPLocalSettings

+ (instancetype)settings;

/*----可配置文件----*/
@property (nonatomic, assign) BOOL hasGlobalTextPath;
@property (nonatomic, assign) BOOL hasPromptTextPath;
@property (nonatomic, assign) BOOL hasPageURLsInfoPath;

@end
