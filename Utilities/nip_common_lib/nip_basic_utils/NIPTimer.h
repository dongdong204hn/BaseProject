//
//  NIPTimer.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  ZBTimerTarget对象避免timer引起的循环引用,在使用timer的controller类里面创建该对象，通过fireBlock来执行动作，controller的dealloc方法里面
 *  调用ZBTimerTarget的invalidate方法
 */
@interface NIPTimer : NSObject
@property(nonatomic,readonly) NSTimeInterval interval;
@property(nonatomic,readonly) NSTimeInterval ellapsedInterval;
@property(nonatomic,readonly) NSUInteger ellapsedTicks;
@property(nonatomic,strong,readonly) NSDate *startDate;

+ (NIPTimer*)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats onFire:(void (^)())fireBlock;
- (void)invalidate;
- (BOOL)isValid;
@end
