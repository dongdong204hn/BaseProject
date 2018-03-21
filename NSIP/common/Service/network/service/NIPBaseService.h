//
//  NIPBaseService.h
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPHttpRequestService.h"

@class CFBaseRequest;

typedef void(^NIPBaseRequestCompleteBlock)(id response);

@interface NIPBaseService : NIPHttpRequestService

+ (instancetype)sharedService;

- (NIPBaseRequest *)requestPath:(NSString *)path
                      withParam:(NSDictionary *)parameters
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete;

- (NIPBaseRequest *)requestPath:(NSString *)path
                      withParam:(NSDictionary *)parameters
      constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete;

- (NIPBaseRequest *)requestPath:(NSString *)path
                      useMehtod:(NIPHttpRequestMethod)method
                      withParam:(NSDictionary *)parameters
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete;

- (NIPBaseRequest *)requestPath:(NSString *)path
                      useMehtod:(NIPHttpRequestMethod)method
                      withParam:(NSDictionary *)parameters
      constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                    forResponse:(Class)modelClass
                     onComplete:(NIPBaseRequestCompleteBlock)onComplete;

@end
