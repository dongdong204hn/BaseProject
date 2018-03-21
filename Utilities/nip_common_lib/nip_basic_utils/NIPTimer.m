//
//  NIPTimer.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPTimer.h"

@implementation NIPTimer {
    NSTimer *_timer;
    NSTimeInterval _ellapsedInterval;
    void (^_fireBlock)();
}

+ (NIPTimer*)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats onFire:(void (^)())fireBlock {
    NIPTimer *timerTarget = [[NIPTimer alloc] init];
    [timerTarget startTimerWithInterval:interval repeats:repeats onFire:fireBlock];
    return timerTarget;
}

- (NSTimeInterval)interval {
    return _timer.timeInterval;
}

- (void)startTimerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats onFire:(void (^)())fireBlock {
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerFired) userInfo:nil repeats:repeats];
    _startDate = [NSDate date];
    _fireBlock = [fireBlock copy];
}

- (void)invalidate {
    [_timer invalidate];
}

- (BOOL)isValid {
    return [_timer isValid];
}

- (void)timerFired {
    if (_fireBlock) {
        _fireBlock();
    }
    _ellapsedInterval += _timer.timeInterval;
    _ellapsedTicks += 1;
}

@end
