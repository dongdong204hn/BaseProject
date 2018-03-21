//
//  NTShareKitQQ.m
//  crowdfunding
//
//  Created by 张杰 on 16/3/31.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NTShareKitQQ.h"
#import "NIPLoginSession.h"

static BOOL registered;
static TencentOAuth *_auth;

@implementation NTShareKitQQ

+ (void)initialize {
    _auth = [[TencentOAuth alloc] initWithAppId:NTShareKitQQAppID andDelegate:nil];
    if (_auth) {
        registered = YES;
    }else{
        registered = NO;
    }

}
- (NTShareKitType)kitType {
    return NTShareKitTypeQQZone;
}

- (NTShareKitStyle)kitStyle {
    return NTShareKitStyleOuter;
}

- (NSString*)kitTitle {
    return self.toFriends?@"QQ空间":@"手机QQ";
}

- (BOOL)hasBind {
    return true;
}

+ (BOOL)qqSupported {
    return [QQApiInterface isQQSupportApi] && registered ;
}

+ (BOOL)qqInstalled{
    return [QQApiInterface isQQInstalled];
}

//纯文本
- (void)postMessage:(NSString*)message {
    [self postMessage:message title:nil thumbImage:nil content:nil];
}

//预览图、预览图+大图、预览图+URL
- (void)postImage:(UIImage *)thumbImage {
    NSData *data = [self compressedImage:thumbImage scaleRatio:0.5 maxLength:1024*1024];
    [self postMessage:nil title:nil thumbImage:thumbImage content:data];
}

- (void)postImage:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image {
     NSData *data = [self compressedImage:image scaleRatio:0.8 maxLength:5*1024*1024];
    [self postMessage:nil title:nil thumbImage:thumbImage content:data];
}

- (void)postImage:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url {
    [self postMessage:nil title:nil thumbImage:thumbImage content:[NSURL URLWithString:url]];
}

//消息+预览图、消息+预览图+大图、消息+预览图+URL
- (void)postMessage:(NSString *)message image:(UIImage *)image {
    NSData *data = [self compressedImage:image scaleRatio:0.5 maxLength:1024*1024];
    [self postMessage:message title:nil thumbImage:image content:data];
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image{
    NSData *data = [self compressedImage:image scaleRatio:0.8 maxLength:5*1024*1024];
    [self postMessage:message title:nil thumbImage:thumbImage content:data];
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url{
    [self postMessage:message title:nil thumbImage:thumbImage content:[NSURL URLWithString:url]];
}

//消息+标题+预览图、消息+标题+预览图+大图、消息+标题+预览图+URL
- (void)postMessage:(NSString*)message title:(NSString *)title image:(UIImage*)image {
    NSData *data = [self compressedImage:image scaleRatio:0.5 maxLength:1024*1024];
    [self postMessage:message title:title thumbImage:image content:data];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image {
    NSData *data = [self compressedImage:image scaleRatio:0.8 maxLength:5*1024*1024];
    [self postMessage:message title:title thumbImage:thumbImage content:data];
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url {
   [self postMessage:message title:title thumbImage:thumbImage content:[NSURL URLWithString:url]];
}

//所有分享入口
- (void)postMessage:(NSString*)message title:(NSString *)title thumbImage:(UIImage*)thumbImage content:(id)content{
    if ([self.delegate respondsToSelector:@selector(shareKitPostBegin:)]) {
        [self.delegate shareKitPostBegin:self];
    }
    QQApiObject *obj = nil;
    NSData *data = [self compressedImage:thumbImage scaleRatio:0.5 maxLength:1014*1024];
    if ([content isKindOfClass:[NSData class]]) {
        obj = [QQApiImageObject objectWithData:(NSData *)content
                                                   previewImageData:data title:title
                                                        description:message];
    }else if ([content isKindOfClass:[NSURL class]]){
        obj = [QQApiNewsObject objectWithURL:(NSURL *)content title:title description:message previewImageData:data];
    }else{//纯文本
        obj = [QQApiTextObject objectWithText:message];
    }
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
    QQApiSendResultCode sendCode = 0;//默认分享成功
    if (self.toFriends) {
       sendCode = [QQApiInterface SendReqToQZone:req];
    }else{
       sendCode = [QQApiInterface sendReq:req];
    }
}

/*
 *图片压缩、若传入空则返回应用icon
 */
- (NSData *)compressedImage:(UIImage *)image scaleRatio:(CGFloat)ratio maxLength:(NSUInteger)length{
    CGFloat scale = 1.0;
    NSData *data = nil;
    do {
        data = UIImageJPEGRepresentation(image, scale);
        scale *= ratio;
        
        //avoid doing endless cycle
        if (scale < 0.01 || data == nil) {
            data = UIImageJPEGRepresentation([UIImage imageNamed:@"appIcon"], 1.0);
            break;
        }
    } while (data.length >= length);
    return data;
}

- (BOOL)handleOpenURL:(NSURL*)url {
    return [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)self];
}


#pragma mark - 登录/回调
- (void)sendAuthRequestWithPermissions:(NSArray *)permissions{
    _auth.sessionDelegate = (id<TencentSessionDelegate>)self;
    [_auth authorize:permissions];
}

- (void)tencentDidLogin{
    [_auth getUserInfo];
    if ([self.authDelegate respondsToSelector:@selector(receiveQQAuthResponse)]) {
        [self.authDelegate receiveQQAuthResponse];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    if ([self.authDelegate respondsToSelector:@selector(receiveQQCancelResponse)]) {
        [self.authDelegate receiveQQCancelResponse];
    }
}

- (void)tencentDidNotNetWork{
    if ([self.authDelegate respondsToSelector:@selector(receiveQQNotNetWorkResponse)]) {
        [self.authDelegate receiveQQNotNetWorkResponse];
    }
}

- (void)getUserInfoResponse:(APIResponse*) response
{
    if ([self.authDelegate respondsToSelector:@selector(getUserInfoResponse:tencentOAuth:)]) {
        [self.authDelegate getUserInfoResponse:response tencentOAuth:_auth];
    }
}

//分享回调
- (void)onResp:(QQBaseResp *)resp{
    if ([resp.result integerValue] == 0) {
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
