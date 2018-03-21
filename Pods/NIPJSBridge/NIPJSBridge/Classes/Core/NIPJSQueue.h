//
//  NIPJSQueue.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/14.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (QueueAdditions)

- (id)cdv_pop;
- (id)cdv_queueHead;
- (id)cdv_dequeue;
- (void)cdv_enqueue:(id)obj;

@end
