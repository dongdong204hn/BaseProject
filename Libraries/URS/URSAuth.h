//
//  URSSession.h
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URSRequest.h"

@class URSAuth;
/**
 * @protocol 
 * 返回URS验证结果给调用者
 */
@protocol URSAuthDelegate <NSObject>
@required
//返回URS登录验证状态信息
- (void)URSAuthLoginSuccessWithToken:(NSString *)authToken andInfo:(NSDictionary *)authInfo;
- (void)URSAuthLoginFail:(NSError *)error;

@optional
//返回URS注销结果
- (void)URSAuthLogoutSuccess;
- (void)URSAuthLogoutFail:(NSError *)error;

//???
- (void)URSAuth:(URSAuth *)auth didExchangeTicket:(NSString *)ticket;
- (void)URSAuth:(URSAuth *)auth didExchangeTicketFailedWithError:(NSError *)error;
@end


/**
 * @class URSAuth 
 * 主要完成URS验证
 */
@interface URSAuth : NSObject <URSRequestDelegate> {
    
}
@property (nonatomic, strong, readonly) NSString *authToken; //缓存的authToken,如果不为nil，表明已登陆
@property (nonatomic, strong, readonly) NSString *appIdFromURS;
@property (nonatomic, strong, readonly) NSString *authUserName; //当前已登陆URS用户名
@property (nonatomic, strong, readonly) NSString *authAliasName; //新注册用户别名,add by xugx
@property (nonatomic, strong, readonly) NSDictionary *authInfo; //当前已登陆账户相关信息
@property (nonatomic, URS_WEAK) id <URSAuthDelegate> delegate;

#pragma mark - initial
/**
 * URS登录验证服务初始化
 * URS登陆认证需要产品代号和版本号(初始化)
 * product：产品代号,由URS分配
 * productVersion:当前软件产品的版本号
 */
- (id)initWithProduct:(NSString *)product andProductVersion:(NSString *)productVersion;


#pragma mark - login method
/**
 * 网易通行证－普通登录
 * otherParam 是除用户名和密码外的其他参数，这些参数对具体产品有特殊含义，请参考URS接口文档
 * 登陆成功后，authToken和authInfo都会被URSAuth缓存起来
 */
- (void)loginURSWithUserName:(NSString *)ursName
                 andPassword:(NSString *)md5Password
               andOtherParam:(NSDictionary *)otherParam;



/*
 * 网易通行证－注册自动登录
 * 注册后使用用户名和加密token,设置为登录状态, add by xugx
 */
- (BOOL)loginURSWithRegResult:(NSString *)result;



/*
 * 第三方登录－SDK登录（目前支持QQ、微信）
 * 通过第三方登录验证获取验证信息，去URS后台换取URStoken及username
 * @param targetType   平台类型,必传
 * @param accessToken  第三方平台获取的授权token，必传
 * @param refreshToken 刷新Token默认传空即可
 * @param openid       开放平台获取的openId,微信必传
 */
- (void)platformLoginGetURSInfoWithTargetType:(long)targetId
                                platformToken:(NSString *)accessToken
                                 refreshToken:(NSString *)refreshToken
                                       openId:(NSString *)openid;


/**
 * 第三方登录－QQWap验证登录
 * 根据登录平台类型和resultUrl获取加密的的登录验证Url
 */
- (NSString *)getURSTokenUrlWithTargetPlatformType:(long)type
                                      andResultURL:(NSString *)resultUrl
                                    andRedirectURL:(NSString *)redirectUrl;



/**
 * 第三方登录－QQWap验证自动登录回调
 * 根据wap验证登录回调处理
 */
-(void) platformWapLoginCallbackWithResultString:(NSString *)resultString;


#pragma mark - logout method

/**
 * 网易通行证－注销
 * 客户端注销URS登陆状态,URS要求客户端注销账户时通知通知server端，因此这个调用会有成功或失败的返回；
   但无论如何，本地缓存的登陆token会被删除，不会妨碍客户端重新登陆；
 */
- (void)logoutURS;


/**
 * 网易通行证－Session失效
 * 使authToken失效，删除本地缓存的token和信息；
   具体产品服务端在验证token时发现已经失效，将这一情况返回给客户端，此时客户端应调用该函数；
   authToken失效发生的原因包括：账户密码被修改....
 */
- (void)invalidToken;
- (void)clearSaveStatus;
- (void)clearToken;


#pragma mark - other method
/*
  使用token置换ticket
 */
- (void)exchangeTicket;

//获取urs id
- (void)doFetchUserAppID;


@end
