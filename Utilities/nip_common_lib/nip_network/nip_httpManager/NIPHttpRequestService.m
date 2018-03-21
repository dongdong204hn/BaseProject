//
//  NIPHttpRequestService.m
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//


#import "NIPHttpRequestService.h"
#import "NIPModelObject.h"
#import "NIPCocoaSecurity.h"
#import "NIPBaseRequest.h"
#import "NIPUtilsFactory.h"
#import "nip_macros.h"

#import "NIPModelHttpResponse.h"

#import "UIDevice+NIPBasicAdditions.h"
#import "NSDictionary+NIPBasicAdditions.h"

#import <AFNetworking/AFNetworking.h>

#define USELOCALDATA 0

#define ERR_TEXT_NETWORK_ERROR @" "
#define NETWORK_TIMEOUT_CODE 10000001
#define NETWORK_ERROR_CODE   10000002


#if USELOCALDATA == 1
#import <JSONKit.h>
#endif


@interface NIPHttpRequestService ()

@property (nonatomic, assign) NSInteger retryTime;

@end


@implementation NIPHttpRequestService

+ (instancetype)sharedService
{
    static NIPHttpRequestService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    return sharedService;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSURL *baseURL = [NSURL URLWithString:@""];
        [self setupHttpManagerWithBaseUrl:baseURL];
    }
    return self;
}

- (void)setupHttpManagerWithBaseUrl:(NSURL *)baseUrl {
    [self setupHttpManagerWithBaseUrl:baseUrl andConfiguration:[self getDefaultSessionConfiguration]];
}

- (void)setupHttpManagerWithBaseUrl:(NSURL *)baseUrl andConfiguration:(NSURLSessionConfiguration *)configuration {
    if (self.httpRequestManager) {
        [self.httpRequestManager.operationQueue cancelAllOperations];
    }
    self.httpRequestManager = [[NIPHTTPSessionManager alloc] initWithBaseURL:baseUrl
                                                        sessionConfiguration:configuration];
    _httpRequestManager.responseSerializer.acceptableContentTypes = [_httpRequestManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    self.retryTimesMap = [NSMutableDictionary dictionary];
    self.timeoutInterval = 20;
}

- (NSURLSessionConfiguration *)getDefaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return configuration;
}

- (void)setBaseUrl:(NSString *)baseUrl
{
    [self.httpRequestManager.operationQueue cancelAllOperations];
    NSURL *baseURL = [NSURL URLWithString:baseUrl];
    [self setupHttpManagerWithBaseUrl:baseURL];
}

- (void)addDefaultHttpHeader:(NSString *)key value:(NSString *)value
{
    [self.httpRequestManager.requestSerializer setValue:value forHTTPHeaderField:key];
}

- (void)setDefaultHttpHeaders:(NSDictionary *)httpHeaders
{
    WEAK_SELF(weakSelf);
    [httpHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [weakSelf.httpRequestManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    if (_timeoutInterval != timeoutInterval) {
        _timeoutInterval = timeoutInterval;
        self.httpRequestManager.requestSerializer.timeoutInterval = timeoutInterval;
    }
}

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                            method:(NIPHttpRequestMethod)method
                        parameters:(NSDictionary *)parameters
                        modelClass:(Class)modelClass
                            encypt:(BOOL)encypt
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    return [self requestWithPath:path
                          method:method
                      parameters:parameters
       constructingBodyWithBlock:nil
                      modelClass:modelClass
                          encypt:encypt
                      onComplete:onComplete];
}

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                            method:(NIPHttpRequestMethod)method
                        parameters:(NSDictionary *)parameters
         constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                        modelClass:(Class)modelClass
                            encypt:(BOOL)encypt
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    NSString *originalPath = path;
    
    
    NSDictionary *encryptParam = parameters;

    if (encypt) {
        if (parameters.count > 0) {
            NSString *paramAsQuery = [parameters convertToQueryStringWithoutURLEncoding];
            NSString *stamp = [NIPCocoaSecurity generateStamp];
            NSData *encryptData = [NIPCocoaSecurity encyptPostData:[paramAsQuery dataUsingEncoding:NSUTF8StringEncoding]
                                                     withStamp:stamp];
            NSString *encyptDataString = [[NSString alloc] initWithData:encryptData encoding:NSUTF8StringEncoding];
            encryptParam = @{ @"data"   : encyptDataString,
                              @"stamp"  : stamp };
        }
    }
    encryptParam = [encryptParam removeEmptyString];
    
#if USELOCALDATA == 1
    id responseObject = [self loadLocalDataWithPath:originalPath];
    if (responseObject) {
        NIPModelHttpResponse *response = [[NIPModelHttpResponse alloc] initWithError:nil];
        response.json = responseObject;
        response.modelObject = [self deserializeJSON:responseObject withModelClass:modelClass];
        if (onComplete) {
            onComplete(nil, response.modelObject);
        }
    }
    else {
        return [self requestRealDataWithPath:path
                                      method:method
                                  parameters:encryptParam
                   constructingBodyWithBlock:block
                                  modelClass:modelClass
                                      encypt:encypt
                                  onComplete:onComplete
                                originalPath:originalPath];
    }
#else
    return [self requestRealDataWithPath:path
                                  method:method
                              parameters:encryptParam
               constructingBodyWithBlock:block
                              modelClass:modelClass
                                  encypt:encypt
                              onComplete:onComplete
                            originalPath:originalPath];
#endif
}

#if USELOCALDATA == 1
- (NSString *)loadLocalDataWithPath:(NSString *)path
{
    NSLog(@"****load local json data with path:%@", path);
    NSString *localDataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:localDataFilePath];
    if ([data bytes]) {
        NSDictionary *localDataMap = [[NSData dataWithContentsOfFile:localDataFilePath] objectFromJSONData];
        return [localDataMap objectForKey:path];
    }
    return nil;
}
#endif

- (NIPBaseRequest *)requestRealDataWithPath:(NSString *)path
                                     method:(NIPHttpRequestMethod)method
                                 parameters:(NSDictionary *)parameters
                  constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                                 modelClass:(Class)modelClass
                                     encypt:(BOOL)encypt
                                 onComplete:(NIPHttpRequestCompleteBlock)onComplete
                               originalPath:(NSString *)originalPath
{
    WEAK_SELF(weakSelf);
    NIPBaseRequest *dataTask =
    [self.httpRequestManager requestWithPath:path
                                      method:method
                                  parameters:parameters
                   constructingBodyWithBlock:block
                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                         STRONG_SELF(strongSelf);
                                         NSString *urlKey = task.currentRequest.URL.absoluteString;
                                         if ([strongSelf.retryTimesMap valueForKey:urlKey]) {
                                             [strongSelf.retryTimesMap removeObjectForKey:urlKey];
                                         }
                                         NIPModelHttpResponse *response = [[NIPModelHttpResponse alloc] initWithError:nil];
                                         response.json = responseObject;
                                         response.modelObject = [weakSelf deserializeJSON:responseObject withModelClass:modelClass];
                                         if (onComplete) {
                                             onComplete(task, response.modelObject);
                                         }
                                     }
                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                         STRONG_SELF(strongSelf);
                                         NSString *urlKey = task.currentRequest.URL.absoluteString;
                                         NSString *retryTimeStr = [strongSelf.retryTimesMap valueForKey:urlKey];
                                         NSInteger retryTime = retryTimeStr ? [retryTimeStr integerValue] : 0;
                                         if (retryTime > 0) {
                                             retryTime--;
                                             [strongSelf.retryTimesMap setValue:@(retryTime) forKey:task.currentRequest.URL.absoluteString];
                                             [strongSelf requestWithPath:originalPath method:method parameters:parameters modelClass:modelClass encypt:encypt onComplete:onComplete];
                                         }
                                         else {
                                             if ([strongSelf.retryTimesMap valueForKey:urlKey]) {
                                                 [strongSelf.retryTimesMap removeObjectForKey:urlKey];
                                             }
                                             NIPModelHttpResponse *response = [[NIPModelHttpResponse alloc] initWithError:error];
                                             response.modelObject = [self deserializeOnError:error withModelClass:modelClass];
                                             if (onComplete) {
                                                 onComplete(task, response.modelObject);
                                             }
                                         }
                                     }];
    if (![self.retryTimesMap valueForKey:dataTask.currentRequest.URL.absoluteString]) {
        [self.retryTimesMap setValue:@(self.retryTime) forKey:dataTask.currentRequest.URL.absoluteString];
    }
    return dataTask;
}

- (NIPBaseRequest *)encryptRequestWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                               modelClass:(Class)modelClass
                               onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    self.retryTime = 1;
    return [self requestWithPath:path
                          method:NIPHttpRequestMethodPost
                      parameters:parameters
                      modelClass:modelClass
                          encypt:YES
                      onComplete:onComplete];
}

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                        modelClass:(Class)modelClass
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    self.retryTime = 1;
    return [self requestWithPath:path
                          method:NIPHttpRequestMethodPost
                      parameters:parameters
                      modelClass:modelClass
                          encypt:NO
                      onComplete:onComplete];
}

- (NIPBaseRequest *)encryptRequestWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                               modelClass:(Class)modelClass
                               retryTimes:(NSInteger)retryTimes
                               onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    self.retryTime = retryTimes;
    return [self requestWithPath:path
                          method:NIPHttpRequestMethodPost
                      parameters:parameters
                      modelClass:modelClass
                          encypt:YES
                      onComplete:onComplete];
}

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                        modelClass:(Class)modelClass
                        retryTimes:(NSInteger)retryTimes
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    self.retryTime = retryTimes;
    return [self requestWithPath:path
                          method:NIPHttpRequestMethodPost
                      parameters:parameters
                      modelClass:modelClass
                          encypt:NO
                      onComplete:onComplete];
}

- (NIPBaseRequest *)requestWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
         constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                        modelClass:(Class)modelClass
                        onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    self.retryTime = 0;
    return [self requestWithPath:path
                          method:NIPHttpRequestMethodPost
                      parameters:parameters
       constructingBodyWithBlock:block
                      modelClass:modelClass
                          encypt:NO
                      onComplete:onComplete];
}

- (NIPBaseRequest *)encryptRequestWithPath:(NSString *)path
                               parameters:(NSDictionary *)parameters
                constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                               modelClass:(Class)modelClass
                               onComplete:(NIPHttpRequestCompleteBlock)onComplete
{
    self.retryTime = 0;
    return [self requestWithPath:path
                          method:NIPHttpRequestMethodPost
                      parameters:parameters
       constructingBodyWithBlock:block
                      modelClass:modelClass
                          encypt:YES
                      onComplete:onComplete];
}


#pragma mark - 数据处理

- (id)deserializeJSON:(id)json withModelClass:(Class)modelClass
{
    if (json) {
        if ([modelClass conformsToProtocol:@protocol(NIPModelObject)]) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                return [[modelClass alloc] initWithJSON:json];
            }
            else if ([json isKindOfClass:[NSArray class]]) {
                NSMutableArray *modelArray = [NSMutableArray array];
                for (NSDictionary *dict in json) {
                    if (![dict isKindOfClass:[NSDictionary class]]) {
                        return nil;
                    }
                    [modelArray addObject:[[modelClass alloc] initWithJSON:dict]];
                }
                return modelArray;
            }
        }
    }
    return nil;
}

- (id)deserializeOnError:(NSError *)error withModelClass:(Class)modelClass
{
    NSDictionary *errorDic = nil;
    if (error.code == -1001) {
        errorDic = @{ @"retdesc" : ERR_TEXT_NETWORK_ERROR,
                      @"retcode" : @NETWORK_TIMEOUT_CODE};
    } else if (error.code == NSURLErrorCancelled) {
        errorDic = @{ @"retdesc" : @"",
                      @"retcode" : @(NSURLErrorCancelled)};
    } else if (![_httpRequestManager.reachabilityManager isReachable]) {
        errorDic = @{ @"retdesc" : ERR_TEXT_NETWORK_ERROR,
                      @"retcode" : @NETWORK_ERROR_CODE};
    }
    NSDictionary *json = errorDic;
    return [self deserializeJSON:json withModelClass:modelClass];
}

@end
