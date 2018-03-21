//
//  NIPAction.m
//  NSIP
//
//  Created by 赵松 on 16/12/26.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPAction.h"
#import "nip_macros.h"

@implementation NIPAction

static NSMutableArray *gActionQueue = nil;

- (void)execute {
    if (gActionQueue==nil) {
        @synchronized([NIPAction class]) {
            if (gActionQueue==nil) {
                gActionQueue = [[NSMutableArray alloc] init];
            }
        }
    }
    if (self.singleAction) {
        for (NIPAction *action in gActionQueue) {
            if ([action class]==[self class]) {
                return;
            }
        }
    }
    [gActionQueue addObject:self];
    [self main];
}

- (void)setComplete {
    [gActionQueue removeObject:self];
}

- (void)main {
    [self setComplete];
}

-(void)dealloc {
    LOG(@"%@:%@",NSStringFromClass(self.class),NSStringFromSelector(_cmd));
}

@end
