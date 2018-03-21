//
//  LDHostHTTPProtocol.h
//  movie163
//
//  Created by Magic Niu on 14-10-10.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDHostHTTPProtocol : NSURLProtocol

/**
 *  NSURLProtocol生效是按照后注册先触发的原则，使用时需要注意
 */
+ (void)start;

/**
 *  当前已经配置的host
 *
 *  @return hostMaps
 */
+ (NSDictionary *)hostMaps;

/**
 *  配置host
 *
 *  @param newHostMaps 为nil时清除host配置
 */
+ (void)setHostMaps:(NSDictionary *)newHostMaps;

@end
