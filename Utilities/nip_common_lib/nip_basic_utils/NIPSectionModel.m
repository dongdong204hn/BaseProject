//
//  NIPSectionModel.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSectionModel.h"

@implementation NIPSectionModel

- (void)addItem:(NSObject*)object {
    [self insertItem:object at:self.itemArray.count];
}

- (void)insertItem:(NSObject*)object at:(NSUInteger)index {
    if ([self.itemArray isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray*)self.itemArray insertObject:object atIndex:index];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.itemArray];
        [array insertObject:object atIndex:index];
        self.itemArray = array;
    }
}

- (void)removeItem:(NSObject*)object {
    if ([self.itemArray isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray*)self.itemArray removeObject:object];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.itemArray];
        [array removeObject:object];
        self.itemArray = array;
    }
}

@end
