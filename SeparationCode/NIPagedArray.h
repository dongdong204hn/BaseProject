//
//  NIPagedArray.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_PAGE_SIZE 20

/**
 *   用来分页缓存某个目标队列
 */
@interface NIPagedArray : NSObject

@property(nonatomic,readonly) NSInteger count;

@property(nonatomic,assign) NSInteger pageSize;
@property(nonatomic,assign) NSInteger pageIndex;
@property(nonatomic,assign) BOOL hasMore;
@property(nonatomic,assign) BOOL hasEverLoaded; //该列表已经加载过数据了，尽管可能list是空的
@property(nonatomic,assign) NSInteger totalCount; //总数，目标列表的总数，不是已加载序列的总数
@property(nonatomic,strong) NSObject *currentPageTag; //当前已加载序列的一个标记，一般用作加载下一页的参数

- (void)clear;
- (void)addObjects:(NSArray*)items;
- (void)addObject:(NSObject*)item;
- (NSUInteger)indexOfObject:(NSObject*)item;
- (id)objectAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
@end
