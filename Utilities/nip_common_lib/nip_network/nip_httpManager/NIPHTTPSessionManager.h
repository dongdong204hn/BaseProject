//
//  NIPHTTPSessionManager.h
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//


#import <AFNetworking/AFNetworking.h>

@class NIPBaseRequest;

typedef NS_ENUM(NSUInteger, NIPHttpRequestMethod) {
    NIPHttpRequestMethodGet,
    NIPHttpRequestMethodPost,
    NIPHttpRequestMethodPut,
    NIPHttpRequestMethodDelete,
};

@interface NIPHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (NIPBaseRequest *)requestWithPath:(NSString *)URLString
                            method:(NIPHttpRequestMethod)method
                        parameters:(id)parameters
         constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


@end
