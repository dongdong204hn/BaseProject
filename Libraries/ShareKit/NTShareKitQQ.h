//
//  NTShareKitQQ.h
//  crowdfunding
//
//  Created by 张杰 on 16/3/31.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NTShareKit.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@protocol QQAuthDelegate <NSObject>

- (void)receiveQQAuthResponse;
- (void)receiveQQCancelResponse;
- (void)receiveQQNotNetWorkResponse;
- (void)getUserInfoResponse:(APIResponse *)response tencentOAuth:(TencentOAuth *)auth;

@end

@interface NTShareKitQQ : NTShareKit

@property (nonatomic, assign) BOOL toFriends;
@property (nonatomic, assign) id<QQAuthDelegate> authDelegate;

+ (BOOL)qqSupported;
+ (BOOL)qqInstalled;
- (void)sendAuthRequestWithPermissions:(NSArray *)permissions;

@end
