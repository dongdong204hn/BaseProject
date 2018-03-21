//
//  NIPKeyValue.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPKeyValue.h"

@implementation NIPKeyValue

- (id)initWithKey:(id)key andValue:(id)value {
    if (self=[super init]) {
        self.key = key;
        self.value = value;
    }
    return self;
}

@end
