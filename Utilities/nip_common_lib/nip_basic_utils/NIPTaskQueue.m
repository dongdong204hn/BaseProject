//
//  NIPTaskQueue.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPTaskQueue.h"

#define MAX_CONCURRENT_COUNT 1

@implementation NIPTaskQueue {
    NSMutableArray *_waitingTaskQueue;
    NSMutableArray *_executingTaskQueue;
    BOOL _started;
}

+ (NIPTaskQueue*)sharedQueue {
    static NIPTaskQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NIPTaskQueue alloc] init];
    });
    return queue;
}


- (instancetype)init {
    if (self=[super init]) {
        _waitingTaskQueue = [NSMutableArray array];
        _executingTaskQueue = [NSMutableArray array];
    }
    return self;
}

- (void)start {
    if (!_started) {
        _started = YES;
        [self dispatchTaskIfNeeded];
    }
}

- (void)enqueueTask:(NIPQueuedTask*)task {
    if ([_waitingTaskQueue indexOfObject:task]!=NSNotFound) {
        return;
    }
    if ([_executingTaskQueue indexOfObject:task]!=NSNotFound) {
        return;
    }
    
    [task addObserver:self forKeyPath:@"taskFinished" options:0 context:nil];
    [_waitingTaskQueue addObject:task];
    [self dispatchTaskIfNeeded];
}


- (void)executeTaskRightNow:(NIPQueuedTask*)task {
    if (!_started) {
        [self enqueueTask:task];
        return;
    }
    
    
    [_waitingTaskQueue removeObject:task];
    if ([_executingTaskQueue indexOfObject:task]!=NSNotFound) {
        return;
    }
    
    [task addObserver:self forKeyPath:@"taskFinished" options:0 context:nil];
    [_executingTaskQueue addObject:task];
    [task execute];
}

- (NSInteger)taskCount {
    return _executingTaskQueue.count+_waitingTaskQueue.count;
}

- (void)dispatchTaskIfNeeded {
    if (!_started) {
        return;
    }
    
    if (_executingTaskQueue.count<MAX_CONCURRENT_COUNT) {
        if (_waitingTaskQueue.count>0) {
            NIPQueuedTask *task = _waitingTaskQueue.firstObject;
            [_waitingTaskQueue removeObjectAtIndex:0];
            [_executingTaskQueue addObject:task];
            [task execute];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"taskFinished"]) {
        if ([_executingTaskQueue containsObject:object]) {
            [object removeObserver:self forKeyPath:@"taskFinished"];
            [_executingTaskQueue removeObject:object];
            [self dispatchTaskIfNeeded];
        }
    }
}

@end
