//
//  NIPQueuedTask.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPQueuedTask.h"


@interface NTQueuedBlockTask : NIPQueuedTask
+ (NTQueuedBlockTask*)taskWithBlock:(void (^)())block;
@end

@implementation NIPQueuedTask

+ (NIPQueuedTask*)taskWithBlock:(void (^)())block {
    return [NTQueuedBlockTask taskWithBlock:block];
}

- (void)execute {
    @try {
        [self startTask];
    }
    @catch (NSException *exception) {
#if DEBUG
        NSLog(@"NIPQueuedTask exeption:\n%@",exception);
#endif
        [self finishTask];
    }
}

- (void)startTask {
    @throw [NSException exceptionWithName:@"NIPQueuedTask" reason:@"NIPQueuedTask subclass should overide -(void)main" userInfo:nil];
}

- (void)finishTask {
    self.taskFinished = YES;
}

@end

@implementation NTQueuedBlockTask {
    void (^_block)();
}

@synthesize taskFinished;

+ (NTQueuedBlockTask*)taskWithBlock:(void (^)())block {
    return [[NTQueuedBlockTask alloc] initWithBlock:block];
}

- (id)initWithBlock:(void (^)())block {
    if (self=[super init]) {
        _block = [block copy];
    }
    return self;
}

- (void)startTask {
    if (_block) {
        _block();
    }
    [self finishTask];
}

@end
