//
//  NIPCommonUtil.m
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPCommonUtil.h"
#import <sys/utsname.h>

@implementation NIPCommonUtil



+ (NSURL *)convertlinkUrl:(NSURL *)url {
    if ([url.absoluteString hasPrefix:NSIP_APPLINK_PREFIX_1]) {
        NSString *innerUrl = [url.absoluteString stringByReplacingOccurrencesOfString:NSIP_APPLINK_PREFIX_1 withString:@"cf163://"];
        return [NSURL URLWithString:innerUrl];
    }
    else if ([url.absoluteString hasPrefix:NSIP_APPLINK_PREFIX_2]) {
        NSString *innerUrl = [url.absoluteString stringByReplacingOccurrencesOfString:NSIP_APPLINK_PREFIX_2 withString:@"cf163://"];
        return [NSURL URLWithString:innerUrl];
    }
    else if ([url.absoluteString hasPrefix:NSIP_APPLINK_PREFIX_3]) {
        NSString *innerUrl = [url.absoluteString stringByReplacingOccurrencesOfString:NSIP_APPLINK_PREFIX_3 withString:@"cf163://"];
        return [NSURL URLWithString:innerUrl];
    }
    return url;
}


@end
