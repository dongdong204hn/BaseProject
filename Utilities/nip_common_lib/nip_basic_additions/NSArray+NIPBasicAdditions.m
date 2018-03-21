//
//  NSArray+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NSArray+NIPBasicAdditions.h"


#pragma mark - NSArray + NTBasicAdditions


@implementation NSArray (NIPBasicAdditions)


- (NSArray *)objectsPassingTest:(BOOL (^)(id object))testBlock
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (testBlock(obj)) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (NSArray *)objectsConvertedBy:(id (^)(id object))convertBlock
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id newObject = convertBlock(obj);
        if (newObject) {
            [array addObject:newObject];
        }
    }];
    return array;
}

- (NSArray *)keysOfPairs {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *pair in self) {
        [array addObject:[[pair allKeys] objectAtIndex:0]];
    }
    return array;
}

- (NSArray *)valuesOfPairs {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *pair in self) {
        [array addObject:[[pair allValues] objectAtIndex:0]];
    }
    return array;
}

- (NSArray *)valuesOfPairsForKeys:(NSArray *)keys {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in keys) {
        for (NSDictionary *pair in self) {
            if ([pair objectForKey:key]) {
                [array addObjectNoDuplication:[pair objectForKey:key]];
                break;
            }
        }
    }
    return array;
}

@end


#pragma mark - NSMutabbleArray + NTBasicAdditions


@implementation NSMutableArray (NTBasicAdditions)


- (void)addObjectNoNil:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

- (void)addObjectNoDuplication:(id)anObject
{
    if (NSNotFound == [self indexOfObject:anObject]) {
        [self addObject:anObject];
    }
}

- (void)insertObjectNoDuplicationAtFirst:(id)anObject
{
    if (NSNotFound == [self indexOfObject:anObject]) {
        [self insertObject:anObject atIndex:0];
    }
}

- (void)insertObjectNoDuplication:(id)anObject atIndex:(NSInteger)index
{
    if (NSNotFound == [self indexOfObject:anObject]) {
        [self insertObject:anObject atIndex:index];
    }
}

@end