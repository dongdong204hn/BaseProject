//
//  NTShareKitYX.h
//  NTShareKit
//
//  Created by zhao song on 14-1-23.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NTShareKit.h"

@interface NTShareKitYX : NTShareKit

@property(nonatomic) BOOL toFriends;

+ (BOOL)yxSupported;
+ (BOOL)yxInstalled;
@end
