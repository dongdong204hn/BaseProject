//
//  UILocalNotification+NIPAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "UILocalNotification+NIPBasicAdditions.h"

@implementation UILocalNotification (NIPBasicAdditions)

- (void)cancel {
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelLocalNotification:self];
}

@end
