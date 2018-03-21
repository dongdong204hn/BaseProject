//
//  NTShareKit.h
//  NTShareKit
//
//  Created by zhao song on 14-1-23.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

//设置分享平台的AppID等 以“网易火车票”为例
#define NTShareKitSinweiboAppID       @"3152833323"
#define NTShareKitSinweiboAppSecret   @"a811adb13f782137dbd15f335e811b9c"
#define NTShareKitSinweiboRedirectURL @"dfdf"

#define NTShareKitWexinAppID          @"wx6e74a4633ddf7d37"
#define NTShareKitWexinAppSecret      @"041ed2c5e15521f49db30ac4551a735a"
#define NTShareKitYiXinAppID          @"yx5cf687ddf0e94923b199f0d97b1a4dd0"

//设置腾讯微博分享的AppID等 以某应用为例
#define NTShareKitQQweiboAppID        @"801189027"
#define NTShareKitQQweiboAppSecret    @"3c220dea270a72c5c56a7b3d9a65c80a"
#define NTShareKitQQweiboRedirectURL  @"https://play.google.com/store/apps/details?id = com.iyuba.voa"
//QQ
#define NTShareKitQQAppID @"1104847291"
//图片缩放后存放的路径
#define NTThumbImagePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"testThumbImage.png"]

/**
 *  分享的平台种类
 */
typedef NS_ENUM(NSInteger, NTShareKitType) {
    NTShareKitTypeYiXin = 1111,
    NTShareKitTypeYiXinFriends,
    NTShareKitTypeWexin,
    NTShareKitTypeWexinFriends,
    NTShareKitTypeSinaWeibo,
    NTShareKitTypeSMS,
    NTShareKitTypeQQWeibo,
    NTShareKitTypeWeibo,
    NTShareKitTypeQQ,
    NTShareKitTypeQQZone
};



/**
 *  分享是内部分享还是外部分享
 */
typedef NS_ENUM(NSInteger, NTShareKitStyle) {
    NTShareKitStyleInner,
    NTShareKitStyleOuter
};

@class NTShareKit;


#pragma mark -

/**
 *  分享组件协议。通过实现相应的方法，执行你想要的操作
 */
@protocol NTShareKitDelegate <NSObject>

@optional

/**
 *  登录授权绑定结束时响应
 */
- (void)shareKit:(NTShareKit *)kit bindComplete:(NSError*)error;

/**
 *  取消帐号绑定时响应
 */
- (void)shareKitBindCancel:(NTShareKit *)kit;

/**
 *  开始分享前响应
 */
- (void)shareKitPostBegin:(NTShareKit *)kit;

/**
 *  分享结束时响应
 */
- (void)shareKit:(NTShareKit *)kit postComplete:(NSError*)error;

/**
 *  取消分享时响应
 */
- (void)shareKitPostCancel:(NTShareKit *)kit;
@end


#pragma mark -

/**
 *  封装分享功能，目前支持的平台有：新浪微博、腾讯微博、微信、易信
 *  通过设定shareMode选择使用傻瓜分享还是定制分享
 *
 */
@interface NTShareKit : NSObject

@property (nonatomic,weak) id<NTShareKitDelegate >  delegate;
@property (nonatomic,weak)     UIViewController *rootViewController;
@property (nonatomic,readonly) NTShareKitType     kitType;
@property (nonatomic,readonly) NTShareKitStyle    kitStyle;
@property (nonatomic,readonly) NSString         * kitTitle;
@property (nonatomic,readonly) BOOL               hasBind;


/**
 *  区分活动分享的出发点
 *  InnerShare是游戏结束后的分享
 *  OuterShare是导航栏的分享
 */
@property (nonatomic) NSString *shareLoc;

/**
 *  按照分享平台的类型，返回相应的ShareKit实例
 *
 *  @param type 分享的类型
 *
 *  @return 相应的ShareKit实例
 */
+ (NTShareKit*)ShareKitWithType:(NTShareKitType)type;

/**
 *  判断是否支持微信、易信、短信分享
 *
 *  @param type 分享的类型
 *
 *  @return 判断结果
 */
+ (BOOL)isShareTypeSupport:(NTShareKitType)type;

/**
 *   处理分享链接的类方法
 *
 *  @param url 分享链接
 *
 *  @return 是否可被处理
 */
+ (BOOL)handleOpenURL:(NSURL*)url;

/**
 *  登录授权
 */
- (void)bind;

/**
 *  取消绑定
 */
- (void)bindOut;

/**
 *  进行文本分享
 *
 *  @param message 要分享的文本内容
 */
- (void)postMessage:(NSString*)message;

/**
 *  进行图片分享
 *
 *  @param message 要分享的文本内容
 */
- (void)postImage:(UIImage *)thumbImage;
- (void)postImage:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image;
- (void)postImage:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url;

/**
 *  进行文本和图片分享
 *
 *  @param message 要分享的文本内容
 *  @param image 要分享的图片
 */
- (void)postMessage:(NSString*)message image:(UIImage*)image;
- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image;
- (void)postMessage:(NSString *)message image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url;

/**
 *  进行标题、文本和图片分享
 *
 *  @param message 要分享的文本内容
 *  @param title 要分享的标题
 *  @param image 要分享的图片
 */
- (void)postMessage:(NSString*)message title:(NSString *)title image:(UIImage*)image;
- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToImageContent:(UIImage *)image;
- (void)postMessage:(NSString *)message title:(NSString *)title image:(UIImage *)thumbImage redirectToLinkContent:(NSString *)url;

/**
 *  处理分享链接
 *
 *  @param url 分享链接
 *
 *  @return 是否可被处理
 */
- (BOOL)handleOpenURL:(NSURL*)url;

/**
 *  屏幕截图
 *
 *  @return 返回当前屏幕截图。
 */
+ (UIImage*)screenshot;

/**
 *  图片缩放
 *
 *  @param image     要缩放的图片
 *  @param thumbSize 要缩放的尺寸
 *  @param percent   图片质量：0~1
 *  @param thumbPath 压缩后的图片存放的位置
 */
+ (void)createThumbImage:(UIImage *)image size:(CGSize )thumbSize percent:(float)percent toPath:(NSString *)thumbPath;

@end

