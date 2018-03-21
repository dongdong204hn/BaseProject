//
//  NIPagedArray.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPagedArray.h"

@implementation NIPagedArray {
    NSMutableArray *_list;
}


- (id)init {
    self = [super init];
    if (self) {
        _list = [NSMutableArray array];
        [self clear];
    }
    return self;
}

- (void)clear {
    [_list removeAllObjects];
    self.pageIndex = 0;
    self.hasMore = NO;
    self.hasEverLoaded = NO;
    self.currentPageTag = nil;
    self.pageSize = DEFAULT_PAGE_SIZE;
}

- (NSInteger)count {
    return _list.count;
}

- (void)addObjects:(NSArray*)items {
    [_list addObjectsFromArray:items];
}

- (void)addObject:(NSObject*)item {
    [_list addObject:item];
}

- (NSUInteger)indexOfObject:(NSObject*)item {
    return [_list indexOfObject:item];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_list objectAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    return [_list removeObjectAtIndex:index];
}

@end
