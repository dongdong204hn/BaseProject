//
//  NTShareKitYX.m
//  NTShareKit
//
//  Created by zhao song on 14-1-23.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NTShareKitYX.h"
#import "YXApi.h"

static BOOL registered;

@implementation NTShareKitYX

+ (void)initialize {
    registered = [YXApi registerApp:NTShareKitYiXinAppID];
}

- (NTShareKitType)kitType {
    return NTShareKitTypeYiXinFriends;
}

- (NTShareKitStyle)kitStyle {
    return NTShareKitStyleOuter;
}


- (NSString*)kitTitle {
    return self.toFriends?@"易信朋友圈":@"易信";
}

- (BOOL)hasBind {
    return true;
}
+ (BOOL)yxInstalled{
    return [YXApi isYXAppInstalled];
}
+ (BOOL)yxSupported {
//#if DEBUG
//    return YES;
//#else
    return [YXApi isYXAppSupportApi]&&registered;
//#endif
}

- (void)postMessage:(NSString*)message {
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    SendMessageToYXReq* req = [[SendMessageToYXReq alloc] init];
    req.text                = message;
    req.bText               = YES;
    if (self.toFriends) {
        req.scene = kYXSceneTimeline;
    } else {
        req.scene = kYXSceneSession;
    }
    
    [YXApi sendReq:req];
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image{
    YXImageObject *ext = [YXImageObject object];
    //Yixin sdk limit size of image under 10M
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
    [self postMessage:message title:@"分享给易信好友" image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url{
    YXWebpageObject *ext = [YXWebpageObject object];
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
    YXImageObject *ext = [YXImageObject object];
    //Yixin sdk limit size of image under 10M
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
    [self postMessage:message title:title image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url {
    YXWebpageObject *ext = [YXWebpageObject object];
    ext.webpageUrl = url;
    [self postMessage:message title:title image:thumbImage andContent:ext];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage andContent:(id)content{
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    
    //Yixin sdk limit size of image under 32K
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
    
    YXMediaMessage *yxMessage = [YXMediaMessage message];
    if (title) {
        yxMessage.title = title;
    }
    yxMessage.msgDescription = message;
    yxMessage.thumbData = data;
    yxMessage.mediaObject = content;
    
    
    SendMessageToYXReq* req  = [[SendMessageToYXReq alloc] init];
    req.message              = yxMessage;
    req.bText                = NO;
    if (self.toFriends) {
        req.scene = kYXSceneTimeline;
    } else {
        req.scene = kYXSceneSession;
    }
    
    [YXApi sendReq:req];
}

- (BOOL)handleOpenURL:(NSURL*)url {
    return [YXApi handleOpenURL:url delegate:(id<YXApiDelegate>)self];
}
- (void)onReceiveResponse: (YXBaseResp *)resp {
    if (resp.code==kYXRespSuccess) {
        if ([self.delegate respondsToSelector:@selector(shareKit:postComplete:)]) {
            [self.delegate shareKit:self postComplete:nil];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(shareKitPostCancel:)]) {
            [self.delegate shareKitPostCancel:self];
        }
    }
}

@end
