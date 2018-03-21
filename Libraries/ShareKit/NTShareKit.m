//
//  NTShareKit.m
//  NTShareKit
//
//  Created by zhao song on 14-1-23.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NTShareKit.h"
//#import "NTShareKitTC.h"
#import "NTShareKitWX.h"
#import "NTShareKitYX.h"
//#import "NTShareKitSMS.h"
#import "NTShareKitWeibo.h"
#import "NTShareKitQQ.h"
#import "nip_macros.h"
//各平台分享链接的前缀
#define NT_SINAWEIBO_SCHEME_PREFIX @"sinaweibosso"
//#define NT_TCWEIBO_SCHEME_PREFIX   @"wb"
#define NT_WX_SCHEME_PREFIX        @"wx"
#define NT_YX_SCHEME_PREFIX        @"yx"
#define NT_QQ_SCHEME_PREFIX        @"tencent"
#define NT_WEIBO_SCHEME_PREFIX @"wb"

@implementation NTShareKit

+ (NTShareKit*)ShareKitWithType:(NTShareKitType)type {
    switch (type) {
        case NTShareKitTypeWeibo:
            return [self weiboKit];
            break;
//        case NTShareKitTypeQQWeibo:
//            return [self tcKit];
//            break;
        case NTShareKitTypeWexin: {
            NTShareKitWX *kit  = [self wxKit];
            kit.toFriends      = NO;
            return kit;
        }
        case NTShareKitTypeWexinFriends:{
            NTShareKitWX *kit  = [self wxKit];
            kit.toFriends      = YES;
            return kit;
        }
        case NTShareKitTypeYiXin:{
            NTShareKitYX *kit  = [self yxKit];
            kit.toFriends      = NO;
            return kit;
        }
        case NTShareKitTypeYiXinFriends:{
            NTShareKitYX *kit  = [self yxKit];
            kit.toFriends      = YES;
            return kit;
        }
        case NTShareKitTypeQQ:{
            NTShareKitQQ *kit = [self qqKit];
            kit.toFriends = NO;
            return kit;
        }
        case NTShareKitTypeQQZone:{
            NTShareKitQQ *kit = [self qqKit];
            kit.toFriends = YES;
            return kit;
        }
//        case NTShareKitTypeSMS: {
//            NTShareKitSMS *kit = [self smsKit];
//            return kit;
//        }
        default:
            break;
    }
    return nil;
}

+ (BOOL)isShareTypeSupport:(NTShareKitType)type {
    if (type==NTShareKitTypeWexin||type==NTShareKitTypeWexinFriends) {
        return [NTShareKitWX wxSupported];
    } else if (type==NTShareKitTypeYiXinFriends||type==NTShareKitTypeYiXin) {
        return [NTShareKitYX yxSupported];
    }else if (type == NTShareKitTypeQQ || type == NTShareKitTypeQQZone){
        return [NTShareKitQQ qqSupported];
    }
//    else if (type==NTShareKitTypeSMS) {
//        return [NTShareKitSMS smsSupported];
//    }
    else if (type == NTShareKitTypeWeibo){ //如果是微博，即使没安装客户端也可以通过web页分享，所以此处可以直接设为yes
        return YES;
    }
    else
        return NO;
    
}


+ (NTShareKitWeibo*)weiboKit {
    static NTShareKitWeibo * sinaKitInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sinaKitInstance = [[NTShareKitWeibo alloc] init];
    });
    return sinaKitInstance;
}

//+ (NTShareKitTC*)tcKit {
//    static NTShareKitTC * tcKitInstance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        tcKitInstance = [[NTShareKitTC alloc] init];
//    });
//    return tcKitInstance;
//}

+ (NTShareKitWX*)wxKit {
    static NTShareKitWX * wxKitInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wxKitInstance = [[NTShareKitWX alloc] init];
    });
    return wxKitInstance;
}

+ (NTShareKitYX*)yxKit {
    static NTShareKitYX * yxKitInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yxKitInstance = [[NTShareKitYX alloc] init];
    });
    return yxKitInstance;
}
+ (NTShareKitQQ*)qqKit{
    static NTShareKitQQ * qqKitInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        qqKitInstance = [[NTShareKitQQ alloc] init];
    });
    return qqKitInstance;
}
//+ (NTShareKitSMS*)smsKit {
//    static NTShareKitSMS * smsKitInstance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        smsKitInstance = [[NTShareKitSMS alloc] init];
//    });
//    return smsKitInstance;
//}

+ (BOOL)handleOpenURL:(NSURL*)url {
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme hasPrefix:NT_WEIBO_SCHEME_PREFIX]){
        [[self weiboKit] handleOpenURL:url];
        return YES;
    }else if ([scheme hasPrefix:NT_WX_SCHEME_PREFIX]){
        [[self wxKit] handleOpenURL:url];
        return YES;
    }else if([scheme hasPrefix:NT_YX_SCHEME_PREFIX]){
        [[self yxKit] handleOpenURL:url];
        return YES;
    }else if([scheme hasPrefix:NT_QQ_SCHEME_PREFIX]){
        [[self qqKit] handleOpenURL:url];
        return YES;
    }
    return NO;
}

- (void)bind {
    return;
}

- (void)bindOut {
    return;
}

- (void)postMessage:(NSString*)message {
    return;
}

- (void)postImage:(UIImage *)thumbImage {
    return;
}

- (void)postImage:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image {
    return;
}

- (void)postImage:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url {
    return;
}

- (void)postMessage:(NSString*)message image:(UIImage*)image {
    return;
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image{
    return;
}

- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url{
    return;
}

- (void)postMessage:(NSString*)message title:(NSString *)title image:(UIImage*)image {
    return;
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image {
    return;
}

- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url {
    return;
}

- (BOOL)handleOpenURL:(NSURL*)url {
    return NO;
}

+ (UIImage*)screenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    //    CGSize imageSize = ViewController.navigationController.view.bounds.size;
//    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
//    else
//        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect contentRectToCrop = CGRectMake(0, 20, SCREEN_WIDTH, 460);
    contentRectToCrop = CGRectMake(0, 20, SCREEN_WIDTH, 460);
    if ([[UIScreen mainScreen]scale]>1.1) {
        contentRectToCrop = CGRectMake(0, 20, 640, 920);
    }
    if ([self isPad]) {
        contentRectToCrop = CGRectMake(0, 20, 768, 1004);
        if ([[UIScreen mainScreen]scale]>1.1) {
            contentRectToCrop = CGRectMake(0, 20, 768*2, 2008);
        }
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], contentRectToCrop);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    return croppedImage;
}

+ (BOOL)isPad {
	BOOL isPad = NO;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
	return isPad;
}

+ (void)createThumbImage:(UIImage *)image size:(CGSize )thumbSize percent:(float)percent toPath:(NSString *)thumbPath {
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat scaleFactor = 0.0;
    CGPoint thumbPoint = CGPointMake(0.0,0.0);
    CGFloat widthFactor = thumbSize.width / width;
    CGFloat heightFactor = thumbSize.height / height;
    if (widthFactor > heightFactor)  {
        scaleFactor = widthFactor;
    }
    else {
        scaleFactor = heightFactor;
    }
    CGFloat scaledWidth  = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    if (widthFactor > heightFactor)
    {
        thumbPoint.y = (thumbSize.height - scaledHeight) * 0.5;
    }
    else if (widthFactor < heightFactor)
    {
        thumbPoint.x = (thumbSize.width - scaledWidth) * 0.5;
    }
    UIGraphicsBeginImageContext(thumbSize);
    CGRect thumbRect = CGRectZero;
    thumbRect.origin = thumbPoint;
    thumbRect.size.width  = scaledWidth;
    thumbRect.size.height = scaledHeight;
    [image drawInRect:thumbRect];
    
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, percent);
    [thumbImageData writeToFile:thumbPath atomically:NO];
}

@end
