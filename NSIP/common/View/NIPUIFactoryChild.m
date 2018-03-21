//
//  NIPUIFactoryChild.m
//  NSIP
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPUIFactoryChild.h"
#import "NIPImageFactoryChild.h"

@implementation NIPUIFactoryChild

+ (UIButton *)naviBackButtonWithTarget:(id)target selector:(SEL)selector
{
    UIButton *button = [self buttonWithImage:[NIPImageFactory navigationBarWhiteBackImage] target:target selector:selector];
    return button;
}

+ (UIButton *)naviBlackBackButtonWithTarget:(id)target selector:(SEL)selector
{
    UIButton *button = [self buttonWithImage:[NIPImageFactory navigationBarBlackBackImage] target:target selector:selector];
    return button;
}

+ (UIButton *)naviPresentBackButtonWithTarget:(id)target selector:(SEL)selector{
    UIButton *button = [self buttonWithImage:[NIPImageFactoryChild navigationBarCloseImage] target:target selector:selector];
    return button;
}


@end
