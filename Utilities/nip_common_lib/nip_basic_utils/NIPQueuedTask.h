//
//  NIPQueuedTask.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  配合NIPTaskQueue使用
 */
@interface NIPQueuedTask : NSObject
@property(nonatomic) BOOL taskFinished; //当一个task完成之后，需要将这个属性赋值为YES
+ (NIPQueuedTask*)taskWithBlock:(void (^)())block;

//如果task被放入队列，队列会调用这个方法来启动task，客户程序不要调用这个方法
- (void)execute;

//子类需要覆盖这个方法
- (void)startTask;
@end