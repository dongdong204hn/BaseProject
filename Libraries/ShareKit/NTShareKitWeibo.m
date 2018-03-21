//
//  NTShareKitWeibo.m
//  trainTicket
//
//  Created by xuejiapeng on 1/31/15.
//  Copyright (c) 2015 netease. All rights reserved.
//

#import "NTShareKitWeibo.h"
#import "WeiboSDK.h"

@implementation NTShareKitWeibo

#define SINA_WEIBO_AUTHINFO_KEY @"SinaWeiboAuthData"
#define SINA_WEIBO_TOKEN_KEY    @"AccessTokenKey"
#define SINA_WEIBO_EXPIRE_KEY   @"ExpirationDateKey"
#define SINA_WEIBO_UID_KEY      @"UserIDKey"


- (id)init {
    if (self=[super init]) {
        [WeiboSDK registerApp:NTShareKitSinweiboAppID];
    }
    return self;
}

- (NTShareKitType)kitType {
    return NTShareKitTypeWeibo;
}

- (NTShareKitStyle)kitStyle {
    return NTShareKitStyleOuter;
}

- (NSString*)kitTitle {
    return @"新浪微博";
}

- (BOOL)hasBind {
    return TRUE;
}


- (void)postMessage:(NSString*)message {
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    [self postMessage:message image:nil];
}

- (void)postMessage:(NSString*)message image:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = NTShareKitSinweiboRedirectURL;
    authRequest.scope = @"all";
    
    WBMessageObject *wbmessage = [WBMessageObject message];
    wbmessage.text = message;
    if (image) {
        WBImageObject *wbimage = [WBImageObject object];
        wbimage.imageData =  UIImagePNGRepresentation(image);
        wbmessage.imageObject = wbimage;
    }

    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:wbmessage authInfo:authRequest access_token:@""];
    [WeiboSDK sendRequest:request];
}

- (BOOL)handleOpenURL:(NSURL*)url {
    return [WeiboSDK handleOpenURL:url delegate:(id<WeiboSDKDelegate>)self];
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        if ([self.delegate respondsToSelector:@selector(shareKit:postComplete:)]) {
            [self.delegate shareKit:self postComplete:nil];
        }
    } else if ([self.delegate respondsToSelector:@selector(shareKitPostCancel:)] && response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            [self.delegate shareKitPostCancel:self];
    }
}

@end
