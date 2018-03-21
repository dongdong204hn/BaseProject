//
//  NIPBaseService.m
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseService.h"
#import "NIPUtilsFactory.h"
#import "nip_macros.h"

#import "UIDevice+NIPBasicAdditions.h"

#import <LDHostHTTPProtocol/LDHostHTTPProtocol.h>



@implementation NIPBaseService


#pragma mark - lifecycle

+ (instancetype)sharedService {
    static NIPBaseService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NIPBaseService alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURL *baseURL = [NSURL URLWithString:HOST];
        [self setupHttpManagerWithBaseUrl:baseURL andConfiguration:[self getCustomConfiguration]];
    }
    return self;
}

- (NSURLSessionConfiguration *)getCustomConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses = @[[LDHostHTTPProtocol class]];
    return configuration;
}

#pragma mark - public mehtod

- (NIPBaseRequest *)requestPath:(NSString *)path
                      withParam:(NSDictionary *)parameters
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete
{
    return [self requestPath:path
                   useMehtod:NIPHttpRequestMethodPost
                   withParam:parameters
   constructingBodyWithBlock:nil
                 forResponse:modelClass
                  onComplete:onComplete];
}
- (NIPBaseRequest *)requestPath:(NSString *)path
                      withParam:(NSDictionary *)parameters
      constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete
{
    return [self requestPath:path
                   useMehtod:NIPHttpRequestMethodPost
                   withParam:parameters
   constructingBodyWithBlock:block
                 forResponse:modelClass
                  onComplete:onComplete];
}

- (NIPBaseRequest *)requestPath:(NSString *)path
                      useMehtod:(NIPHttpRequestMethod)method
                      withParam:(NSDictionary *)parameters
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete {
    return [self requestPath:path
                   useMehtod:method
                   withParam:parameters
   constructingBodyWithBlock:nil
                 forResponse:modelClass
                  onComplete:onComplete];
}

- (NIPBaseRequest *)requestPath:(NSString *)path
                      useMehtod:(NIPHttpRequestMethod)method
                      withParam:(NSDictionary *)parameters
      constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete {
    parameters = [self addEnvInfoToParameters:parameters];
    NIPBaseRequest *request = nil;
    if ([path hasPrefix:@"encrypt"]) {
        request = [self requestWithPath:path
                                 method:method
                             parameters:parameters
              constructingBodyWithBlock:block
                             modelClass:modelClass
                                 encypt:YES
                             onComplete:^(NSURLSessionDataTask *task, id responseObject) {
                                 if (onComplete) {
                                     onComplete(responseObject);
                                 }
                             }];
    }
    else {
        request = [self requestWithPath:path
                                 method:method
                             parameters:parameters
              constructingBodyWithBlock:block
                             modelClass:modelClass
                                 encypt:NO
                             onComplete:^(NSURLSessionDataTask *task, id responseObject) {
                                 if (onComplete) {
                                     onComplete(responseObject);
                                 }
                             }];
    }
    return request;
}

- (NSDictionary *)addEnvInfoToParameters:(NSDictionary *)params {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    NSDictionary *commonParams = @{ @"uniqueId":EMPTY_STRING_IF_NIL([NIPUtilsFactory uuid])
                                    , @"deviceId":EMPTY_STRING_IF_NIL([NIPUtilsFactory uuid])
                                    , @"systemName":EMPTY_STRING_IF_NIL(@"")
                                    , @"systemVersion":EMPTY_STRING_IF_NIL(@([UIDevice systemMainVersion]))
                                    , @"deviceType":@"iphone"
                                    , @"productVersion":EMPTY_STRING_IF_NIL(APP_VERSION)
                                    , @"channel":EMPTY_STRING_IF_NIL([UIDevice getChannelString])
                                    , @"apiLevel":@14 };
    [dict addEntriesFromDictionary:commonParams];
    //    [dict addEntriesFromDictionary:@{ @"deviceId" : [NIPUtilsFactory uuid],
    //                                      @"mobileType" : OS_TYPE,
    //                                      @"channel" : [UIDevice getChannelString],
    //                                      @"ver" : APP_VERSION,
    //                                      @"mobile_os_version" : [[UIDevice currentDevice] systemVersion],
    //                                      @"mobile_type_version" : [UIDevice getProcessorInfo],
    //                                      @"api_version" : APIVERSION }];
    
    return [dict copy];
}



@end
