//
//  NTShareKitWX.h
//  NTShareKit
//
//  Created by zhao song on 14-1-23.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NTShareKit.h"
#import "WXApi.h"

@protocol WXAuthDelegate <NSObject>

- (void)receiveWXAuthResponse:(SendAuthResp *)response;
- (void)receiveWXCancelResponse:(SendAuthResp *)response;

@end

@interface NTShareKitWX : NTShareKit

@property (nonatomic) BOOL toFriends;
@property (nonatomic,assign) id<WXAuthDelegate> authDelegate;

+ (BOOL)wxSupported;
+ (BOOL)wxInstalled;
- (BOOL)sendAuthRequestInViewController:(UIViewController *)viewController;
@end
