//
//  NIPWebNavigationController.m
//  NSIP
//
//  Created by Eric on 16/10/14.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPWebNavigationController.h"

@implementation NIPWebNavigationController

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ( self.presentedViewController)
    {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}


@end
