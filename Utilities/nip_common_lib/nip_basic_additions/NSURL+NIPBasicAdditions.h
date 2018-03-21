//
//  NSURL+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  NSURL NTBasicAdditions
 */
@interface NSURL (NIPBasicAdditions)

/**
 * @brief 返回一个不含参数的 url。如果原始 url 不含参数，则直接返回原始 url。
 * @return 去除了参数的 url。
 */
- (NSURL *)urlByRemoveQuery;

/**
 * @brief 比较当前 URL 与 aURL 是否相等。
 */
- (BOOL)isEquivalent:(NSURL *)aURL;

/**
 * @brief 在当前 url 结尾添加新的参数 parameter，并返回新的 url。
 * @param query 需要添加的参数。
 * @return 添加了新参数后的 url。
 */
- (NSURL *)urlByAppendQuery:(NSDictionary *)query;

/**
 *  @return 返回一个NSDictionary对象, 其key-value与原url地址中所有参数-值对一一对应.
 */
- (NSDictionary *)parametersDictionary;

/**
 *  @return 返回一个由url各级地址组成的NSArray, 各元素的顺序与url地址中相一致.
 */
- (NSArray *)getPathComponents;

@end
