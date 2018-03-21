//
//  URSSession.m
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#import "URSAuth.h"
#import "UIDevice+URS.h"
#import "NSData+URS.h"
#import "NSString+URS.h"

//登录相关接口url
#define URL_FETCH_APPID @"http://reg.163.com/services/initMobApp"
#define URL_LOGIN @"http://reg.163.com/services/safeUserLoginForMob"
#define URL_LOGOUT @"http://reg.163.com/services/safeRemoveMobToken"

#define URL_EXCHANGE_TIKET @"http://reg.163.com/interfaces/mobileapp/exchangeTicketByMobToken.do"
#define URL_EXCHANGE_URSTOKEN  @"http://reg.163.com/outerLogin/oauth2/exchageMobLoginToken.do"
#define URL_GET_URSTOKEN  @"http://reg.163.com/outerLogin/oauth2/connect.do?"
#define URL_GET_OPENTOKEN @"http://reg.163.com/outerLogin/oauth2/get_access_token.do?"

//本地持久化缓存Key
#define USER_DEFAULT_APP_ID @"URS_USER_APP_ID"
#define USER_AES_KEY      @"USER_AES_KEY"
#define USER_DEFAULT_TOKEN @"URS_AUTH_TOKEN"
#define USER_DEFAULT_INFO @"URS_AUTH_INFO"
#define USER_DEFAULT_NAME @"URS_AUTH_NAME"
#define USER_DEFAULT_VERSION @"URS_AUTH_VERSION"
#define USER_DEFAULT_PRODUCT @"URS_AUTH_PRODUCT"
#define USER_DEFAULT_RESULT  @"http://cp.163.com"

//接口url 参数Key
#define PARAM_PRODUCT @"product"
#define PARAM_PRODUCT_VERSION @"pdtVersion"
#define PARAM_MAC @"mac"
#define PARAM_UNIQUE_ID @"uniqueID"
#define PARAM_DEVICE_TYPE @"deviceType"
#define PARAM_SYSTEM_NAME @"systemName"
#define PARAM_SYSTEM_VERSION @"systemVersion"
#define PARAM_RESOLUTION @"resolution"
#define PARAM_USERNAME @"username"
#define PARAM_PASSWORD @"password"
#define PARAM_ID @"id"
#define PARAM_TOKEN @"token"

//第三方平台登录key
#define PARAM_PLATFORM_OPENID @"openid"
#define PARAM_PLARFORM_TARGET @"target"
#define PARAM_PLATFORM_TOKEN  @"access_token"
#define PARAM_PLATFORM_REFRESH_TOKEN @"refresh_token"


//错误封装方法
static NSError *authError(NSInteger code, NSString *description) {
    if (description == nil) {
        description = @"";
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObject:description
                                                     forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"urs登录失败" code:code userInfo:dict];
}



@interface URSAuth ()
//使用property来规避兼容ARC和非ARC带来的麻烦
@property (nonatomic, strong, readwrite) NSString *authToken;
@property (nonatomic, strong, readwrite) NSString *aesKey;
@property (nonatomic, strong, readwrite) NSString *appIdFromURS;
@property (nonatomic, strong, readwrite) NSString *authUserName;
@property (nonatomic, strong, readwrite) NSString *authAliasName; //新注册用户别名,add by xugx
@property (nonatomic, strong, readwrite) NSDictionary *authInfo;

@property (nonatomic, assign) BOOL loginPendingForID;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSString *product;
@property (nonatomic, strong) NSString *productVersion;
@property (nonatomic, strong) NSString *inputUserName;
@property (nonatomic, strong) NSString *inputPassword;
@property (nonatomic, strong) NSDictionary *inputParam;
@property (nonatomic, strong) NSString *platformResultStr;

@property (nonatomic, strong) URSRequest *loginRequest;
@property (nonatomic, strong) URSRequest *logoutRequest;
@property (nonatomic, strong) URSRequest *fechIdRequest;
@property (nonatomic, strong) URSRequest *ticketRequest;
@property (nonatomic, strong) URSRequest *platformLoginRequest;
@property (nonatomic, strong) URSRequest *ursInfoRequest;

@end



@implementation URSAuth
@synthesize authUserName = _authUserName;
@synthesize aesKey = _aesKey;
@synthesize appIdFromURS = _appIdFromURS;
@synthesize authToken = _authToken;
@synthesize authInfo = _authInfo;

@synthesize error = _error;
@synthesize loginPendingForID;

@synthesize product = _product;
@synthesize productVersion = _productVersion;
@synthesize inputUserName = _inputUserName;
@synthesize inputPassword = _inputPassword;
@synthesize inputParam = _inputParam;

@synthesize loginRequest = _loginRequest;
@synthesize logoutRequest = _logoutRequest;
@synthesize fechIdRequest = _fechIdRequest;
@synthesize ticketRequest = _ticketRequest;
@synthesize platformLoginRequest = _platformLoginRequest;



@synthesize delegate = _delegate;

#pragma mark - initial method

- (id)initWithProduct:(NSString *)product andProductVersion:(NSString *)productVersion
{
    assert(product != nil && productVersion != nil);
    self = [super init];
    if (self) {
        self.product = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_PRODUCT];
        self.productVersion = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_VERSION];
        self.appIdFromURS = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_APP_ID];
        self.aesKey = [[NSUserDefaults standardUserDefaults] objectForKey:USER_AES_KEY];
        self.authToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_TOKEN];
        self.authInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_INFO];
        self.authUserName = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULT_NAME];

        if (![self.product isEqualToString:product]) {
            self.product = product;
            self.productVersion = productVersion;
            [[NSUserDefaults standardUserDefaults] setObject:self.product forKey:USER_DEFAULT_PRODUCT];
            [[NSUserDefaults standardUserDefaults] setObject:self.productVersion forKey:USER_DEFAULT_VERSION];

            self.appIdFromURS = nil;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_APP_ID
            ];
            [self clearLogState];
        }
        if(![self.productVersion isEqualToString:productVersion]){
            self.productVersion = productVersion;
            [[NSUserDefaults standardUserDefaults] setObject:self.productVersion forKey:USER_DEFAULT_VERSION];
        }
        if (self.appIdFromURS == nil) {
            [self doFetchUserAppID];
        }
    }
    return self;
}

- (void)doFetchUserAppID
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.product forKey:PARAM_PRODUCT];
    [params setValue:self.productVersion forKey:PARAM_PRODUCT_VERSION];
    UIDevice *device = [UIDevice currentDevice];
    [params setValue:[device urs_macaddress] forKey:PARAM_MAC];
    [params setValue:[device urs_uniqueID] forKey:PARAM_UNIQUE_ID];
    [params setValue:[device name] forKey:PARAM_DEVICE_TYPE];
    [params setValue:[device systemName] forKey:PARAM_SYSTEM_NAME];
    [params setValue:[device systemVersion] forKey:PARAM_SYSTEM_VERSION];
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSInteger w = rect.size.width * [UIScreen mainScreen].scale;
    NSInteger h = rect.size.height * [UIScreen mainScreen].scale;
    NSString *screenSize = [NSString stringWithFormat:@"%ld*%ld", (long)w, (long)h];
    [params setValue:screenSize forKey:PARAM_RESOLUTION];
    
    self.fechIdRequest = [URSRequest reqquest];
    self.fechIdRequest.delegate = self;
    [self.fechIdRequest postWithUrl:URL_FETCH_APPID
                           andParam:params];
}


- (void)dealloc
{
    URS_SUPERDEALLOC
    self.product = nil;
    self.productVersion = nil;

    self.loginRequest = nil;
    self.logoutRequest = nil;
    self.fechIdRequest = nil;
    self.platformLoginRequest = nil;
    self.ursInfoRequest = nil;

    self.inputUserName = nil;
    self.inputPassword = nil;
    self.inputParam = nil;
    self.platformResultStr = nil;
    self.appIdFromURS = nil;
    self.authUserName = nil;
    self.authToken = nil;
    self.authInfo = nil;

    self.error = nil;
}


#pragma mark - handle login&logout method
- (void)loginURSWithUserName:(NSString *)ursName
                 andPassword:(NSString *)md5Password
               andOtherParam:(NSDictionary *)otherParam
{
    if (ursName.length == 0 || md5Password.length == 0) {
        self.error = authError(400, @"无效用户名或密码");
        [self performSelector:@selector(doLoginComplete) withObject:nil afterDelay:0];
        return;
    }
    //[self clearLogState];//token只在特定情况下需要清除，没必要每次登录就清除
    [self clearRequests];
    self.inputUserName = nil;
    self.inputPassword = nil;
    self.inputParam = nil;
    self.platformResultStr = nil;
    self.inputUserName = ursName;
    self.inputPassword = md5Password;
    self.inputParam = otherParam;
    if (self.appIdFromURS) {
        [self doLogin];
    } else {
        self.loginPendingForID = YES;
        [self doFetchUserAppID];
    }
}

- (void)logoutURS
{
    [self clearRequests];
    [self doLogout];
}

- (void)doLogin
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.inputParam];
    [params setValue:self.inputUserName forKey:PARAM_USERNAME];
    [params setValue:[self.inputPassword urs_md5] forKey:PARAM_PASSWORD];
    [params setValue:[[UIDevice currentDevice] urs_uniqueID] forKey:PARAM_UNIQUE_ID];
    [params setValue:@"1" forKey:@"needmainaccount"];//拿别名
    //NSLog(@"%@",params);
    NSString *result = [URSRequest paramatersWithDictionary:params];
    NSData *aesdata = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString *resultString = [[aesdata urs_AES256EncryptWithKey:self.aesKey] urs_base16String];
    [params removeAllObjects];
    [params setValue:resultString forKey:@"params"];
    [params setValue:self.appIdFromURS forKey:PARAM_ID];
    self.loginRequest = [URSRequest reqquest];
    self.loginRequest.delegate = self;
    [self.loginRequest postWithUrl:URL_LOGIN
                          andParam:params];
}

- (void)dologinPlatForm{
    NSData *aesdata = [self.platformResultStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result= [[aesdata urs_AES256EncryptWithKey:self.aesKey] urs_base16String];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:result forKey:@"params"];
    [params setValue:self.appIdFromURS forKey:PARAM_ID];
    self.platformLoginRequest = [URSRequest reqquest];
    self.platformLoginRequest.delegate = self;
    [self.platformLoginRequest postWithUrl:URL_EXCHANGE_URSTOKEN
                                  andParam:params];
}
- (void)doLogout
{
    if (self.authToken.length == 0) {
        [self performSelector:@selector(doLogoutComplete) withObject:nil afterDelay:0];
        return;
    }
    self.logoutRequest = [URSRequest reqquest];
    self.logoutRequest.delegate = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.authToken forKey:PARAM_TOKEN];
    NSString *result = [URSRequest paramatersWithDictionary:params];
    NSData *aesdata = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString *resultString = [[aesdata urs_AES256EncryptWithKey:self.aesKey] urs_base16String];
    [params removeAllObjects];
    [params setValue:resultString forKey:@"params"];
    [params setValue:self.appIdFromURS forKey:PARAM_ID];
    [self.logoutRequest postWithUrl:URL_LOGOUT
                           andParam:params];
    
    //[self clearLogState];
    [self clearToken]; //在退出登录时只清除Token, 2013.10.30.xuguoxing
}

- (void)doLoginComplete
{
    if (self.error) {
        [self.delegate URSAuthLoginFail:self.error];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.authToken forKey:USER_DEFAULT_TOKEN];
        
        NSUserDefaults *widgetDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.widget.datashare"];
        [widgetDefaults setObject:self.authToken forKey:USER_DEFAULT_TOKEN];
        [widgetDefaults setObject:self.appIdFromURS forKey:USER_DEFAULT_APP_ID];
        [widgetDefaults synchronize];
        //NSLog(@"%@",self.authInfo);
        if ([self.authInfo objectForKey:PARAM_USERNAME]) {
            self.authUserName = [self.authInfo objectForKey:PARAM_USERNAME];
            if ([self.authUserName rangeOfString:@"@"].location == NSNotFound) {
                self.authUserName = [self.authUserName stringByAppendingString:@"@163.com"];
            }
        } else {
            self.authUserName = self.inputUserName;
        }
        [defaults setObject:self.authUserName forKey:USER_DEFAULT_NAME];
        if (self.authInfo) {
            [defaults setObject:self.authUserName forKey:USER_DEFAULT_INFO];
        } else {
            [defaults removeObjectForKey:USER_DEFAULT_INFO];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.delegate URSAuthLoginSuccessWithToken:self.authToken andInfo:self.authInfo];
    }
    [self clearRequests];
}

- (void)doLogoutComplete
{
    if (self.error) {
        if ([self.delegate respondsToSelector:@selector(URSAuthLogoutFail:)]) {
            [self.delegate URSAuthLogoutFail:self.error];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(URSAuthLogoutSuccess)]) {
            [self.delegate URSAuthLogoutSuccess];
        }
    }
    [self clearRequests];
}


#pragma mark - 第三方登录(QQ、微信)
- (void)platformLoginGetURSInfoWithTargetType:(long)targetId
                                platformToken:(NSString *)accessToken
                                 refreshToken:(NSString *)refreshToken
                                       openId:(NSString *)openid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (accessToken) {
        [params setObject:accessToken forKey:PARAM_PLATFORM_TOKEN];
    }
    [params setObject:[NSString stringWithFormat:@"%ld",(long)targetId] forKey:PARAM_PLARFORM_TARGET];
    if (refreshToken) {
        [params setObject:refreshToken forKey:PARAM_PLATFORM_REFRESH_TOKEN];
    } else {
        [params setObject:@"" forKey:PARAM_PLATFORM_REFRESH_TOKEN];
    }
    if (openid) {
        [params setObject:openid forKey:PARAM_PLATFORM_OPENID];
    }
    
    //例：@{@"target":@"1",@"access_token":@"",@"refresh_token":@""};
    self.platformResultStr = [URSRequest paramatersWithDictionary:params];

    if (self.appIdFromURS) {
        [self dologinPlatForm];
    } else{
        self.loginPendingForID = YES;
        [self doFetchUserAppID];
    }

}

//根据resultURL和redirectURL获取URS_TOKEN
- (NSString *)getURSTokenUrlWithTargetPlatformType:(long)type
                                      andResultURL:(NSString *)resultUrl
                                    andRedirectURL:(NSString *)redirectUrl{
    NSString *ursTokenURL = @"";
    //示例：otherParam = @{@"target":@"1",@"url":@"cp.163.com",@"display":@"mobile"};
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (type > 0) {
        [params setObject:[NSString stringWithFormat:@"%ld",(long)type] forKey:PARAM_PLARFORM_TARGET];
    } else {
        if (!self.error) {
            self.error = authError(401, @"登录失败");
        }
        if ([self.delegate respondsToSelector:@selector(URSAuthLoginFail:)]) {
            [self.delegate URSAuthLoginFail:self.error];
        }
        return ursTokenURL;
    }
    
    if (resultUrl) {
        [params setObject:resultUrl forKey:@"url"];
    } else {
        NSLog(@"参数不合法");
        if (!self.error) {
            self.error = authError(401, @"登录失败");
        }
        if ([self.delegate respondsToSelector:@selector(URSAuthLoginFail:)]) {
            [self.delegate URSAuthLoginFail:self.error];
        }
        return ursTokenURL;
    }
    
    //失败重定向的url
    if (redirectUrl) {
        [params setObject:redirectUrl forKey:@"url2"];
    }
    
    //将display设为mobile,则登陆页面效果是手机端的登陆效果，若不设置，显示为PC端效果
    [params setValue:@"mobile" forKey:@"display"];
    [params setValue:self.product forKey:PARAM_PRODUCT];
    [params setValue:self.appIdFromURS forKey:PARAM_ID];
    
    NSString *string = [URSRequest paramatersWithDictionary:params];
    ursTokenURL = [NSString stringWithFormat:@"%@%@",URL_GET_URSTOKEN,string];

    return ursTokenURL;
}


//根据wap验证登录回调处理
-(void) platformWapLoginCallbackWithResultString:(NSString *)resultString{
    NSMutableDictionary *dict = [self parseAESResult:resultString];
    if (dict[PARAM_USERNAME] && dict[PARAM_TOKEN]) {
        self.authToken = [dict objectForKey:PARAM_TOKEN];
        self.authUserName = [dict objectForKey:PARAM_USERNAME];
        [dict removeObjectForKey:PARAM_TOKEN];
        self.authInfo = dict;
        [self doLoginComplete];
        /*
         //获取用户QQ的uid 和access_token
         NSMutableDictionary *params = [NSMutableDictionary dictionary];
         [params setValue:self.authToken forKey:PARAM_TOKEN];
         [params setValue:self.appIdFromURS forKey:PARAM_ID];
         self.ursInfoRequest = [URSRequest reqquest];
         self.ursInfoRequest.delegate = self;
         [self.ursInfoRequest postWithUrl:URL_GET_OPENTOKEN
         andParam:params];
         */
        //[navController dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (!self.error) {
            self.error = authError(401, @"登录失败");
        }
        if ([self.delegate respondsToSelector:@selector(URSAuthLoginFail:)]) {
            [self.delegate URSAuthLoginFail:self.error];
        }
    }
}



#pragma mark - clear method
- (void)invalidToken
{
    [self clearLogState];
}

- (void)clearRequests
{
    [self.loginRequest cancel];
    [self.logoutRequest cancel];
    [self.fechIdRequest cancel];
    [self.platformLoginRequest cancel];
    [self.ursInfoRequest cancel];
    self.loginRequest = nil;
    self.logoutRequest = nil;
    self.fechIdRequest = nil;
    self.platformLoginRequest = nil;
    self.ursInfoRequest = nil;
    self.error = nil;
    self.loginPendingForID = NO;
    self.platformResultStr = nil;
}

- (void)clearLogState
{
    self.appIdFromURS = nil;
    self.authUserName = nil;
    self.aesKey = nil;
    self.authToken = nil;
    self.authInfo = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USER_DEFAULT_APP_ID];
    [defaults removeObjectForKey:USER_DEFAULT_TOKEN];
    [defaults removeObjectForKey:USER_DEFAULT_INFO];
    [defaults removeObjectForKey:USER_DEFAULT_NAME];
    [defaults removeObjectForKey:USER_AES_KEY];
    
    //widget app group
    NSUserDefaults *widgetDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.widget.datashare"];
    [widgetDefaults removeObjectForKey:USER_DEFAULT_APP_ID];
    [widgetDefaults removeObjectForKey:USER_DEFAULT_TOKEN];
    [widgetDefaults synchronize];
    
}

//只清除Token方法，在退出登录时调用,2013.10.30.xuguoxing
- (void)clearToken
{
    self.authToken = nil;
    self.authInfo = nil;
    self.authAliasName = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USER_DEFAULT_TOKEN];
    [defaults removeObjectForKey:USER_DEFAULT_INFO];
    
    //widget app group
    NSUserDefaults *widgetDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.widget.datashare"];
    [widgetDefaults removeObjectForKey:USER_DEFAULT_TOKEN];
    [widgetDefaults removeObjectForKey:USER_DEFAULT_APP_ID];
    [widgetDefaults synchronize];
}

- (void)clearSaveStatus
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USER_DEFAULT_APP_ID];
    [defaults removeObjectForKey:USER_DEFAULT_TOKEN];
    [defaults removeObjectForKey:USER_DEFAULT_INFO];
    [defaults removeObjectForKey:USER_DEFAULT_NAME];
    [defaults removeObjectForKey:USER_AES_KEY];
    
    //widget app group
    NSUserDefaults *widgetDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.widget.datashare"];
    [widgetDefaults removeObjectForKey:USER_DEFAULT_APP_ID];
    [widgetDefaults removeObjectForKey:USER_DEFAULT_TOKEN];
    [widgetDefaults synchronize];
}

#pragma mark -
#pragma mark URSRequest delegate

- (NSMutableDictionary *)parseAESResult:(NSString *)result
{
    //NSLog(@"%@",[[result base16Data] AES256DecryptWithKey:self.aesKey]);
    NSString *str = [[NSString alloc] initWithData:[[result urs_base16Data] urs_AES256DecryptWithKey:self.aesKey] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *filedPairs = [str componentsSeparatedByString:@"&"];
    for (NSString *pairString in filedPairs) {
        NSArray *pair = [pairString componentsSeparatedByString:@"="];
        if (pair.count == 2) {
            [dict setObject:[pair objectAtIndex:1]
                     forKey:[pair objectAtIndex:0]];
        }
    }
    return dict;
}

- (NSMutableDictionary *)thirdPlatformLoginParseAESResult:(NSString *)result
{
    //NSLog(@"%@",[[result base16Data] AES256DecryptWithKey:self.aesKey]);
    NSString *str = [[NSString alloc] initWithData:[[result urs_base16Data] urs_AES256DecryptWithKey:self.aesKey] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [self platformLoginHandleResponse:str];
    //NSLog(@"%@",dict);
    return dict;
}

- (void)request:(URSRequest *)request success:(NSString *)responseString
{
    if (request == self.ursInfoRequest) {
        /*
        //暂时不需要通过URS获取第三方平台uid及access_token
        NSMutableDictionary *dict = [self platformTokenParseResponse:responseString];
        
        NSString *result = [dict objectForKey:@"result"];
        if (!result && !self.error) {
            self.error = authError(401, @"登录失败");
            //return;
        }
        NSMutableDictionary *tokenDict = [self parseAESResult:result];
        NSLog(@"tokenDIct %@",tokenDict);
        //第三方平台uid及access_token
        self.authToken = [tokenDict objectForKey:PARAM_TOKEN];
        self.authAliasName = [tokenDict objectForKey:@"aliasuser"];
        [tokenDict removeObjectForKey:PARAM_TOKEN];
        self.authInfo = tokenDict;
        
        [self doLoginComplete];
         */
    }
    else if (request == self.platformLoginRequest) { //该request返回数据格式与其他不同
        NSMutableDictionary *dict = [self platformLoginParseResponse:responseString];
        
        NSString *result = [dict objectForKey:@"result"];
        if (!result && !self.error) {
            self.error = authError(401, @"登录失败");
        }
        NSMutableDictionary *tokenDict = [self thirdPlatformLoginParseAESResult:result];
        self.authToken = [tokenDict objectForKey:PARAM_TOKEN];
        self.authUserName = [tokenDict objectForKey:PARAM_USERNAME];
        [tokenDict removeObjectForKey:PARAM_TOKEN];
        self.authInfo = tokenDict;
        [self doLoginComplete];
        
    }
    else {
        NSMutableDictionary *dict = [self parseResponse:responseString];
        if (request == self.loginRequest) {
            NSString *result = [dict objectForKey:@"result"];
            if (!result && !self.error) {
                self.error = authError(401, @"登录失败");
                //return;
            }
            NSMutableDictionary *tokenDict = [self parseAESResult:result];
            //NSLog(@"tokenDIct %@",tokenDict);
            if(!self.error){
                self.authToken = [tokenDict objectForKey:PARAM_TOKEN];
            }
            self.authAliasName = [tokenDict objectForKey:@"aliasuser"];
            [tokenDict removeObjectForKey:PARAM_TOKEN];
            self.authInfo = tokenDict;
            [self doLoginComplete];
        } else if (request == _logoutRequest) {
            [self doLogoutComplete];
        } else if (request == _fechIdRequest) {
            self.appIdFromURS = [dict objectForKey:@"id"];
            self.aesKey = [dict objectForKey:@"key"];
            if (self.appIdFromURS) {
                [[NSUserDefaults standardUserDefaults] setObject:self.appIdFromURS
                                                          forKey:USER_DEFAULT_APP_ID];
                //widget app group
                NSUserDefaults *widgetDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.widget.datashare"];
                [widgetDefaults setObject:self.appIdFromURS forKey:USER_DEFAULT_APP_ID];
            }
            if (self.aesKey) {
                [[NSUserDefaults standardUserDefaults] setObject:self.aesKey
                                                          forKey:USER_AES_KEY];
            }
            
            if (self.loginPendingForID) {
                self.loginPendingForID = NO;
                if (self.appIdFromURS) {
                    if (self.platformResultStr) {
                        [self dologinPlatForm];
                    } else{
                        [self doLogin];
                    }
                } else {
                    self.error = authError(403, @"服务器认证出错");
                    [self doLoginComplete];
                }
            }
        } else if (request == _ticketRequest) {
            [self didExchangeTicket:responseString];
        }
    }
}

- (void)request:(URSRequest *)request fail:(NSError *)error
{
    self.error = error;
    if (request == _loginRequest) {
        [self doLoginComplete];
    }
    else if (request == _logoutRequest) {
        [self doLogoutComplete];
    }
    else if (request == _fechIdRequest) {
        [self doLoginComplete];
    }
    else if (request == _ticketRequest) {
        [self didExchangeTicketFailed:error];
    }
    else if (request == _platformLoginRequest) {
        [self doLoginComplete];
    }
    else if (request == _ursInfoRequest) {
        [self doLoginComplete];
    }
}

/**
返回值的模式是：
line1：code
line2: description
line3: empty line
line4: filed values, filed1=value1&field2=value2...
*/
- (NSMutableDictionary *)parseResponse:(NSString *)response
{
    NSInteger errorCode = 404;
    NSArray *array = [response componentsSeparatedByString:@"\n"];
    if (array.count > 0) {
        NSString *codeStr = [array objectAtIndex:0];
        errorCode = [codeStr intValue];
    }

    NSMutableDictionary *responseDict = nil;
    if (errorCode >= 200 && errorCode < 300) {
        if (array.count > 3) {
            responseDict = [NSMutableDictionary dictionary];
            NSString *filedValues = [array objectAtIndex:3];
            NSArray *filedPairs = [filedValues componentsSeparatedByString:@"&"];
            for (NSString *pairString in filedPairs) {
                NSArray *pair = [pairString componentsSeparatedByString:@"="];
                if (pair.count == 2) {
                    [responseDict setObject:[pair objectAtIndex:1]
                                     forKey:[pair objectAtIndex:0]];
                }
            }
        }
    }
    else {
        if (errorCode == 401) { //401和427需要清空token
            self.error = authError(errorCode, @"登录失败，请重试");
            [self clearLogState];
        } else if (errorCode == 402) {
            self.error = authError(errorCode, @"登录错误次数过多");
        } else if (errorCode == 412) {
            if (array.count > 1) {
                NSString *secondCodeStr = [array objectAtIndex:1];
                NSInteger secondErrorCode = [secondCodeStr intValue];
                if (secondErrorCode == 414 || secondErrorCode == 415) {
                    self.error = authError(errorCode, @"登录失败次数过多，请明天再试");
                } else {
                    self.error = authError(errorCode, @"登录失败次数过多，请用电脑登录www.lmlc.com");
                }
            } else {
                self.error = authError(errorCode, @"登录失败次数过多，请用电脑登录www.lmlc.com");
            }
        } else if (errorCode == 420) {
            self.error = authError(errorCode, @"该帐号不存在");
        } else if (errorCode == 422) {
            self.error = authError(errorCode, @"该帐号已被锁定，请解锁后重试");
        } else if (errorCode == 423) {
            self.error = authError(errorCode, @"该帐号冻结中，请续费后重试");
        } else if (errorCode == 427) {
            self.error = authError(errorCode, @"登录失败，请重试");
            [self clearLogState];
        } else if (errorCode == 433) {
            self.error = authError(errorCode, @"登录失败，请重试");
        } else if (errorCode == 460) {
            if (array.count > 1) {
                NSString *secondCodeStr = [array objectAtIndex:1];
                NSInteger secondErrorCode = [secondCodeStr intValue];
                if (secondErrorCode == 416 || secondErrorCode == 417 || secondErrorCode == 418) {
                    self.error = authError(errorCode, @"登录失败次数过多，请明天再试");
                } else if (secondErrorCode == 419) {
                    self.error = authError(errorCode, @"登录操作过于频繁，请稍后再试");
                } else {
                    self.error = authError(errorCode, @"密码错误");
                }
            } else {
                self.error = authError(errorCode, @"密码错误");
            }
        } else if (errorCode == 500) {
            self.error = authError(errorCode, @"系统忙，请稍后再试");
        } else if (errorCode == 503) {
            self.error = authError(errorCode, @"系统忙，请稍后再试");
        } else {
            self.error = authError(errorCode, @"登录失败");
        }
    }

    return responseDict;
}

#pragma mark - 第三方登录时URS相关数据处理

- (NSMutableDictionary *)platformTokenParseResponse:(NSString *)response
{
    NSInteger errorCode = 404;
    NSArray *array = [response componentsSeparatedByString:@"\n"];
    if (array.count > 0) {
        NSString *codeStr = [array objectAtIndex:0];
        errorCode = [codeStr intValue];
    }
    NSMutableDictionary *responseDict = nil;
    if (errorCode >= 200 && errorCode < 300) {
        responseDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < [array count]; i++) {
            if ([array[i] hasPrefix:@"result"]) {
                NSArray *pair = [array[i] componentsSeparatedByString:@"="];
                if (pair.count == 2) {
                    [responseDict setObject:[pair objectAtIndex:1]
                                     forKey:[pair objectAtIndex:0]];
                    break;
                }
            }
        }
    } else {
        if (errorCode == 401) {
            self.error = authError(errorCode, @"登录失败，请重试");
        } else if (errorCode == 500) {
            self.error = authError(errorCode, @"系统忙，请稍后再试");
        } else if (errorCode == 503) {
            self.error = authError(errorCode, @"系统忙，请稍后再试");
        } else {
            self.error = authError(errorCode, @"登录失败");
        }
    }
    
    return responseDict;
}

//处理结果字符串转化为字典
- (NSMutableDictionary *)platformLoginHandleResponse:(NSString *)response
{
    //示例：response = @"{"result":"8FCD012F99839ABFCBC3B","retCode":"200","retDesc":"操作成功"}"
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *aString = [response stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    NSString *bString = [aString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *array = [bString componentsSeparatedByString:@","];
    
    for (int i = 0; i < [array count]; i++) {
        NSString *string = array[i];
        NSArray *tempAray = [string componentsSeparatedByString:@":"];
        if ([tempAray count] == 2) {
            dict[tempAray[0]] = tempAray[1];
        }
    }
    return dict;
}
//解析错误码等
- (NSMutableDictionary *)platformLoginParseResponse:(NSString *)response
{
    NSMutableDictionary *dict = [self platformLoginHandleResponse:response];
    //NSLog(@"responseArray %@",dict);
    //错误码
    NSInteger errorCode = 404;
    NSString *codeStr = dict[@"retCode"];
    if ([codeStr isKindOfClass:[NSString class]]) {
        errorCode = [codeStr intValue];
    }
    
    if (errorCode == 200) {
        NSLog(@"置换Token解析成功");
        return dict;
    } if (errorCode == 401) {
        self.error = authError(errorCode, @"登录失败，请重试");
    } else if (errorCode == 402) {
        self.error = authError(errorCode, @"登录错误次数过多");
    } else if (errorCode == 420) {
        self.error = authError(errorCode, @"该帐号不存在");
    } else if (errorCode == 422) {
        self.error = authError(errorCode, @"该帐号已被锁定，请解锁后重试");
    } else if (errorCode == 423) {
        self.error = authError(errorCode, @"该帐号冻结中，请续费后重试");
    } else if (errorCode == 427) {
        self.error = authError(errorCode, @"登录失败，请重试");
    } else if (errorCode == 433) {
        self.error = authError(errorCode, @"登录失败，请重试");
    } else if (errorCode == 500) {
        self.error = authError(errorCode, @"系统忙，请稍后再试");
    } else if (errorCode == 503) {
        self.error = authError(errorCode, @"系统忙，请稍后再试");
    } else {
        self.error = authError(errorCode, @"登录失败");
    }
    
    return dict;
}

#pragma mark 注册成功后,设置为已登录状态

- (BOOL)loginURSWithRegResult:(NSString *)result
{
    NSMutableDictionary *tokenDict = [self parseAESResult:result];
    NSString *userName = [tokenDict objectForKey:PARAM_USERNAME];
    NSString *token = [tokenDict objectForKey:PARAM_TOKEN];
    NSString *alias = [tokenDict objectForKey:@"alias"];
    if (userName && token) {
        self.authUserName = userName;
        if ([self.authUserName rangeOfString:@"@"].location == NSNotFound) {
            self.authUserName = [self.authUserName stringByAppendingString:@"@163.com"];
        }
        self.authToken = token;
        self.authAliasName = alias;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.authToken forKey:USER_DEFAULT_TOKEN];
        [defaults setObject:self.authUserName forKey:USER_DEFAULT_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSUserDefaults *widgetDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.widget.datashare"];
        [widgetDefaults setObject:self.authToken forKey:USER_DEFAULT_TOKEN];
        [widgetDefaults setObject:self.appIdFromURS forKey:USER_DEFAULT_APP_ID];
        [widgetDefaults synchronize];

        return YES;
    }
    return NO;
}

#pragma mark Ticket


- (void)exchangeTicket
{
    if (!self.appIdFromURS || !self.authToken) {
        NSError *error = authError(0, @"urs置换Ticket:app或token为空");
        if (self.delegate && [self.delegate respondsToSelector:@selector(URSAuth:didExchangeTicketFailedWithError:)]) {
            [self.delegate URSAuth:self didExchangeTicketFailedWithError:error];
        }
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.appIdFromURS forKey:PARAM_ID];

    NSDictionary *tokenParam = @{PARAM_TOKEN : self.authToken};
    NSString *result = [URSRequest paramatersWithDictionary:tokenParam];
    NSData *aesdata = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSString *resultString = [[aesdata urs_AES256EncryptWithKey:self.aesKey] urs_base16String];

    [params setValue:resultString forKey:@"params"];

    self.ticketRequest = [URSRequest reqquest];
    self.ticketRequest.delegate = self;
    [self.ticketRequest postWithUrl:URL_EXCHANGE_TIKET
                           andParam:params];
}

- (void)didExchangeTicket:(NSString *)responseString
{
    NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    if (!responseData) {
        NSError *error = authError(0, @"exchangeTicket:返回数据为空");
        [self didExchangeTicketFailed:error];
        return;
    }

    NSError *error;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [self didExchangeTicketFailed:error];
        return;
    }


    if (![responseDic isKindOfClass:[NSDictionary class]]) {
        NSError *error = authError(0, @"response invalid format");
        [self didExchangeTicketFailed:error];
        return;
    }

    NSString *encrytTicket = [responseDic valueForKey:@"ticket"];
    NSString *ticket = [[NSString alloc] initWithData:[[encrytTicket urs_base16Data] urs_AES256DecryptWithKey:self.aesKey] encoding:NSUTF8StringEncoding];

    NSInteger code = [[responseDic valueForKey:@"retCode"] integerValue];
    NSString *retDesc = [responseDic valueForKey:@"retDesc"] ?: @"";

    if (ticket && [ticket isKindOfClass:[NSString class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(URSAuth:didExchangeTicket:)]) {
            [self.delegate URSAuth:self didExchangeTicket:ticket];
        }
    } else {
        NSError *error = authError(code, retDesc);
        [self didExchangeTicketFailed:error];
    }
}

- (void)didExchangeTicketFailed:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(URSAuth:didExchangeTicketFailedWithError:)]) {
        [self.delegate URSAuth:self didExchangeTicketFailedWithError:error];
    }
    return;

}


@end
