//
//  NSArray+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - NSArray + NTBasicAdditions
/**
 *  NSArray NTBasicAdditions
 */
@interface NSArray (NIPBasicAdditions)


/**
 *  筛选数组中符合特定条件testBlock的元素.
 *
 *  @param testBlock 筛选条件. 参数object是array中的元素, 返回值BOOL代表object是否通过test.
 *
 *  @return Array中所有通过Test的元素组成的array, 返回array中各元素的相对位置与原array中相对应. 若原array中没有通过测试的元素, 则返回空array.
 */
- (NSArray *)objectsPassingTest:(BOOL (^)(id object))testBlock;

/**
 *  使用特定规则convertBlock对数组元素进行转化.
 *  
 *  @param convertBlock 转化规则. 参数object是array中的元素, 返回值是被convert之后的object.
 *
 *  @return Array中所有元素被convertBlock之后组成的新array, 各元素位置与原array相对应. 若原array为空, 则返回空array.
 */
- (NSArray *)objectsConvertedBy:(id (^)(id object))convertBlock;

/// 获取所有字典元素的key
- (NSArray *)keysOfPairs;

/// 获取所有字典元素的value
- (NSArray *)valuesOfPairs;

/// 获取keys对应的values
- (NSArray *)valuesOfPairsForKeys:(NSArray *)keys;

@end


#pragma mark - NSMutableArray + NTBasicAdditions
/**
 *  NSMutableArray NTBasicAdditions
 */
@interface NSMutableArray (NTBasicAdditions)

/**
 *  添加非nil元素, 如果是nil则不添加.
 *
 *  @param anObject 要添加的元素, 如果是nil则不添加.
 */
- (void)addObjectNoNil:(id)anObject;

/**
 *  在数组末尾无重复地添加anObject, 如果anObject与数组中元素重复则不添加.
 */
- (void)addObjectNoDuplication:(id)anObject;

/**
 *  在数组头部无重复地插入anObject, 如果anObject与数组中元素重复则不添加.
 */
- (void)insertObjectNoDuplicationAtFirst:(id)anObject;

/**
 *  在数组位置index无重复地插入anObject, 如果anObject与数组中元素重复则不添加.
 */
- (void)insertObjectNoDuplication:(id)anObject atIndex:(NSInteger)index;

@end
