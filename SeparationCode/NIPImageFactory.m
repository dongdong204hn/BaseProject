//
//  NIPImageFactory.m
//  NSIP
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPImageFactory.h"

@implementation NIPImageFactory

+ (UIImage *)navigationBarBackgroundImage {
    return [[UIImage imageNamed:@"nip_navigationBar_bgImage"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
}


+ (UIImage *)navigationBarBlackBackImage {
    return [UIImage imageNamed:@"nip_black_back_btn"];
}

+ (UIImage *)navigationBarWhiteBackImage {
    return [UIImage imageNamed:@"nip_white_back_btn"];
}

//+ (UIImage *)navigationBarCloseImage {
//    return [UIImage imageNamed:@"close_present"];
//}

@end
