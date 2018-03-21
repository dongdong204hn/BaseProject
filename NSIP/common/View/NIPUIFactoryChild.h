//
//  NIPUIFactoryChild.h
//  NSIP
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPUIFactory.h"

@interface NIPUIFactoryChild : NIPUIFactory

+ (UIButton *)naviBackButtonWithTarget:(id)target
                              selector:(SEL)selector;
+ (UIButton *)naviBlackBackButtonWithTarget:(id)target
                                   selector:(SEL)selector;
+ (UIButton *)naviPresentBackButtonWithTarget:(id)target
                                     selector:(SEL)selector;

@end
