//
//  NIPURLHandler.m
//  NSIP
//
//  Created by 赵松 on 17/3/16.
//  Copyright © 2017年 netease. All rights reserved.
//

#import "NIPURLHandler.h"

@implementation NIPURLHandler

+ (instancetype)sharedHandler {
    static NIPURLHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NIPURLHandler alloc] init];
    });
    return sharedInstance;
}

//- (BOOL)openUrl:(NSURL *)url inController:(UIViewController *)controller {
//    return NO;
//}
//
//- (BOOL)openStringUrl:(NSString *)url inController:(UIViewController *)controller {
//    return NO;
//}
//
//- (BOOL)openExternalUrl:(NSURL *)url inController:(UIViewController *)controller {
//    return NO;
//}

@end
