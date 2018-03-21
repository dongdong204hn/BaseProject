//
//  NIPHttpRequestService.h
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "NIPHTTPSessionManager.h"

typedef void (^NIPHttpRequestCompleteBlock)(NSURLSessionDataTask *task, id responseObject);

@interface NIPHttpRequestService : NSObject

@property (nonatomic, strong) NIPHTTPSessionManager *httpRequestManager;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, strong) NSMutableDictionary *retryTimesMap;

+ (instancetype)sharedService;

- (void)setBaseUrl:(NSString *)baseUrl;

- (void)setupHttpManagerWithBaseUrl:(NSURL *)baseUrl
                   andConfiguration:(NSURLSessionConfiguration *)configuration;

- (void)addDefaultHttpHeader:(NSString *)key value:(NSString *)value;

- (void)setDefaultHttpHeaders:(NSDictionary *)httpHeaders;

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                            method:(NIPHttpRequestMethod)method
                        parameters:(NSDictionary *)parameters
                        modelClass:(Class)modelClass
                            encypt:(BOOL)encypt
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete;

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                            method:(NIPHttpRequestMethod)method
                        parameters:(NSDictionary *)parameters
         constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                        modelClass:(Class)modelClass
                            encypt:(BOOL)encypt
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete;

/**
 *  加密参数的GET网络请求
 *
 *  @param path       url
 *  @param parameters 参数
 *  @param modelClass 返回model
 *  @param onComplete 结果回调
 *
 */
- (NIPBaseRequest *)encryptRequestWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                               modelClass:(Class)modelClass
                               onComplete:(NIPHttpRequestCompleteBlock)onComplete;

/**
 *  GET网络请求
 *
 *  @param path       url
 *  @param parameters 参数
 *  @param modelClass 返回model
 *  @param onComplete 结果回调
 *
 */
- (NIPBaseRequest *)requestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                        modelClass:(Class)modelClass
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete;

/**
 *  加密参数的GET网络请求
 *
 *  @param path       url
 *  @param parameters 参数
 *  @param modelClass 返回model
 *  @param retryTimes 重试次数
 *  @param onComplete 结果回调
 *
 */
- (NIPBaseRequest *)encryptRequestWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                               modelClass:(Class)modelClass
                               retryTimes:(NSInteger)retryTimes
                               onComplete:(NIPHttpRequestCompleteBlock)onComplete;

- (NIPBaseRequest *)encryptRequestWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                               modelClass:(Class)modelClass
                               onComplete:(NIPHttpRequestCompleteBlock)onComplete;

/**
 *  GET网络请求
 *
 *  @param path       url
 *  @param parameters 参数
 *  @param modelClass 返回model
 *  @param retryTimes 重试次数
 *  @param onComplete 结果回调
 *
 */
- (NIPBaseRequest *)requestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                        modelClass:(Class)modelClass
                        retryTimes:(NSInteger)retryTimes
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete;

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
         constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                        modelClass:(Class)modelClass
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete;



@end
