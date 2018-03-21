//
//  NIPHttpResponse.m
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import "NIPHttpResponse.h"

@implementation NIPHttpResponse

- (instancetype)initWithError:(NSError*)error {
    if (self=[super init]) {
        self.error = error;
    }
    return self;
}

- (instancetype)init {
    return [self initWithError:nil];
}

@end
