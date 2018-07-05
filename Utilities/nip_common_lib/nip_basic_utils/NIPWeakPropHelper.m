//
//  NIPWeakPropHelper.m
//  NSIP
//
//  Created by 赵松 on 2018/6/12.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NIPWeakPropHelper.h"

@interface NIPWeakPropHelper() {
    NIPDeallocBlock _block;
}

@end

@implementation NIPWeakPropHelper

- (id)initWithBlock:(NIPDeallocBlock)block {
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

+ (instancetype)helperWithDeallocBlock:(NIPDeallocBlock)block {
    NIPWeakPropHelper *instance = [[NIPWeakPropHelper alloc] initWithBlock:block];
    return instance;
}

- (void)dealloc {
    if (_block) {
        _block();
        NSLog(@"song dealloc:%@", [self class]);
    }
}

@end
