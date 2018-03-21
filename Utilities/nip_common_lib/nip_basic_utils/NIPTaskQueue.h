//
//  NIPTaskQueue.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPQueuedTask.h"


/**
 *  一个任务队列，区别于NSOperationQueue,在主线程执行
 *  可以用来支持Command设计模式
 */
@interface NIPTaskQueue : NSObject
+ (NIPTaskQueue*)sharedQueue;

//启动taskQueue,队列里面的task将会被调度执行
//在start之前，可以enqueueTask将task放到队列里面
- (void)start;

//将task放到队列里面
//将会检task的重复性，通过-(BOOL)isEqual，对于重复的task会忽略
- (void)enqueueTask:(NIPQueuedTask*)task;

//立即执行task
//如果队列尚未start，效果与enqueueTask一样
//页会检查task的重复性，如果有一个重复的task2在队列里面，但尚未开始执行，task2将会被删除；如果有一个重复的task2，且已经开始执行，task将会被忽略
- (void)executeTaskRightNow:(NIPQueuedTask*)task;


- (NSInteger)taskCount;

@end
