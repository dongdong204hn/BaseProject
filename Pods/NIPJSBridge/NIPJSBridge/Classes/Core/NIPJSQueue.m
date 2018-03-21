
//
//  NIPJSQueue.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/14.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSQueue.h"


@implementation NSMutableArray (QueueAdditions)


- (id)cdv_queueHead {
    if (self.count) {
        return self[0];
    }
    return nil;
}


- (__autoreleasing id)cdv_dequeue {
    if (self.count) {
        id head = self[0];
        [self removeObjectAtIndex:0];
        return head;
    }
    return nil;
}

- (id)cdv_pop {
    return [self cdv_dequeue];
}


- (void)cdv_enqueue:(id)object {
    [self addObject:object];
}




@end
