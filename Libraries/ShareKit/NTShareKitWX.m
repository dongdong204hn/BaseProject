//
//  NTShareKitWX.m
//  NTShareKit
//
//  Created by zhao song on 14-1-23.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NTShareKitWX.h"
#import "WXApi.h"


@interface NTShareKitWX ()

@property (nonatomic, strong) WXApi *wx;

@end

static BOOL registered;

@implementation NTShareKitWX

+ (void)initialize {
    registered = [WXApi registerApp:NTShareKitWexinAppID];
}

- (NTShareKitType)kitType {
    return NTShareKitTypeWexinFriends;
}

- (NTShareKitStyle)kitStyle {
    return NTShareKitStyleOuter;
}

- (NSString*)kitTitle {
    return self.toFriends?@"微信朋友圈":@"微信";
}

- (BOOL)hasBind {
    return true;
}
+ (BOOL)wxInstalled{
    return [WXApi isWXAppInstalled];
}
+ (BOOL)wxSupported {
    return [WXApi isWXAppSupportApi]&&registered;
}

- (void)postMessage:(NSString*)message {
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = message;
    req.bText = YES;
    if (self.toFriends) {
        req.scene = WXSceneTimeline;
    } else {
        req.scene = WXSceneSession;
    }
    
    [WXApi sendReq:req];
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image{
    WXImageObject *ext = [WXImageObject object];
    //wechat sdk limit size of image under 10M
    CGFloat scale = 1.0;
    NSData *data = nil;
    do {
        data = UIImageJPEGRepresentation(image, scale);
        scale *= 0.8;
        
        //avoid doing endless cycle
        if (scale < 0.01 || data == nil) {
            data = UIImageJPEGRepresentation([UIImage imageNamed:@"appIcon"], 1.0);
            break;
        }
    } while (data.length >= 10*1024*1024);
    ext.imageData = data;
    [self postMessage:message title:@"分享给微信好友" image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url{
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    [self postMessage:message title:nil image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message image:(UIImage *)image {
    [self postMessage:message title:nil image:image andContent:nil];
}

- (void)postMessage:(NSString*)message title:(NSString *)title image:(UIImage*)image {
    [self postMessage:message title:title image:image andContent:nil];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image {
    WXImageObject *ext = [WXImageObject object];
    //wechat sdk limit size of image under 10M
    CGFloat scale = 1.0;
    NSData *data = nil;
    do {
        data = UIImageJPEGRepresentation(image, scale);
        scale *= 0.8;
        
        //avoid doing endless cycle
        if (scale < 0.01 || data == nil) {
            data = UIImageJPEGRepresentation([UIImage imageNamed:@"appIcon"], 1.0);
            break;
        }
    } while (data.length >= 10*1024*1024);
    ext.imageData = data;
    [self postMessage:message title:title image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url {
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    [self postMessage:message title:title image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage andContent:(id)content {
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    
    //wechat sdk limit size of image under 32K
    CGFloat scale = 1.0;
    NSData *data = nil;
    do {
        data = UIImageJPEGRepresentation(thumbImage, scale);
        scale *= 0.5;
        
        //avoid doing endless cycle
        if (scale < 0.01 || data == nil) {
            data = UIImageJPEGRepresentation([UIImage imageNamed:@"appIcon"], 1.0);
            break;
        }
    } while (data.length >= 32*1024);
    
    WXMediaMessage *wxMessage = [WXMediaMessage message];
    if (self.toFriends) {
        wxMessage.title = message;
    } else {
        if (title) {
            wxMessage.title = title;
        }
        wxMessage.description = message;
    }
    wxMessage.thumbData = data;
    wxMessage.mediaObject = content;
    
    SendMessageToWXReq* req  = [[SendMessageToWXReq alloc] init];
    req.message              = wxMessage;
    req.bText                = NO;
    if (self.toFriends) {
        req.scene = WXSceneTimeline;
    } else {
        req.scene = WXSceneSession;
    }
    
    [WXApi sendReq:req];
}

- (void)postImage:(UIImage *)thumbImage {
    [self postImage:thumbImage andContent:nil];
}

- (void)postImage:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image {
    WXImageObject *ext = [WXImageObject object];
    //wechat sdk limit size of image under 10M
    CGFloat scale = 1.0;
    NSData *data = nil;
    do {
        data = UIImageJPEGRepresentation(image, scale);
        scale *= 0.5;
        
        //avoid doing endless cycle
        if (scale < 0.01 || data == nil) {
            data = UIImageJPEGRepresentation([UIImage imageNamed:@"appIcon"], 1.0);
            break;
        }
    } while (data.length >= 10*1024*1024);
    ext.imageData = data;
    [self postImage:thumbImage andContent:ext];
}

- (void)postImage:(UIImage *)thumbImage andContent:(id)content {
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    
    //wechat sdk limit size of image under 32K
    CGFloat scale = 1.0;
    NSData *data = nil;
    do {
        data = UIImageJPEGRepresentation(thumbImage, scale);
        scale *= 0.5;
        
        //avoid doing endless cycle
        if (scale < 0.01 || data == nil) {
            data = UIImageJPEGRepresentation([UIImage imageNamed:@"appIcon"], 1.0);
            break;
        }
    } while (data.length >= 32*1024);
    
    WXMediaMessage *wxMessage = [WXMediaMessage message];
    [wxMessage setThumbImage:[UIImage imageWithData:data]];
    wxMessage.mediaObject = content;
    SendMessageToWXReq* req  = [[SendMessageToWXReq alloc] init];
    req.message              = wxMessage;
    req.bText                = NO;
    if (self.toFriends) {
        req.scene = WXSceneTimeline;
    } else {
        req.scene = WXSceneSession;
    }
    
    [WXApi sendReq:req];
}

- (BOOL)sendAuthRequestInViewController:(UIViewController *)viewController {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope =  @"snsapi_userinfo"; // @"post_timeline,sns"
    req.state =  @"lmlc";
    req.openID = NTShareKitWexinAppSecret;
    
    return [WXApi sendAuthReq:req
               viewController:viewController
                     delegate:(id<WXApiDelegate>)self];
}

- (BOOL)handleOpenURL:(NSURL*)url {
    return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self];
}

- (void) onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode==WXSuccess) {
            if ([self.delegate respondsToSelector:@selector(shareKit:postComplete:)]) {
                [self.delegate shareKit:self postComplete:nil];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(shareKitPostCancel:)]) {
                [self.delegate shareKitPostCancel:self];
            }
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode ==WXSuccess) {
            if (self.authDelegate
                && [self.authDelegate respondsToSelector:@selector(receiveWXAuthResponse:)]) {
                SendAuthResp *authResp = (SendAuthResp *)resp;
                [self.authDelegate receiveWXAuthResponse:authResp];
            }
        } else{
            if (self.authDelegate
                && [self.authDelegate respondsToSelector:@selector(receiveWXCancelResponse:)]) {
                SendAuthResp *authResp = (SendAuthResp *)resp;
                [self.authDelegate receiveWXCancelResponse:authResp];
            }
        }

    }
}

@end
