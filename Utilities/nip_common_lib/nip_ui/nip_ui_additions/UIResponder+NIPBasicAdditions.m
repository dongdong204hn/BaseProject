//
//  UIResponder+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/23.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "UIResponder+NIPBasicAdditions.h"

static __weak id currentFirstResponder;

@implementation UIResponder (NIPBasicAdditions)

+(id)currentFirstResponder{
    currentFirstResponder = nil;
    [[UIApplication sharedApplication]sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

-(void)findFirstResponder:(id)sender{
    currentFirstResponder = self;
}

@end
