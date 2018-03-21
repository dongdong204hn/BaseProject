//
//  NIPHTTPSessionManager.m
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import "NIPHTTPSessionManager.h"
#import "NIPBaseRequest.h"

@implementation NIPHTTPSessionManager

+ (instancetype)sharedManager {
    static NIPHTTPSessionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NIPBaseRequest *)requestWithPath:(NSString *)URLString
                                     method:(NIPHttpRequestMethod)method
                                 parameters:(id)parameters
                  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    switch (method) {
        case NIPHttpRequestMethodGet:
            return (NIPBaseRequest *)[self GET:URLString
                                    parameters:parameters
                                      progress:nil
                                       success:success
                                       failure:failure];
            break;
            
        case NIPHttpRequestMethodPost:
            if (block) {
                 return (NIPBaseRequest *)[self POST:URLString
                                          parameters:parameters
                           constructingBodyWithBlock:block
                                            progress:nil
                                             success:success
                                             failure:failure];
            } else {
                return (NIPBaseRequest *)[self POST:URLString
                                         parameters:parameters
                                           progress:nil
                                            success:success
                                            failure:failure];
            }
            break;
            
        case NIPHttpRequestMethodPut:
            return (NIPBaseRequest *)[self PUT:URLString
                                    parameters:parameters
                                       success:success
                                       failure:failure];
            break;
            
        case NIPHttpRequestMethodDelete:
            return (NIPBaseRequest *)[self DELETE:URLString
                                       parameters:parameters
                                          success:success
                                          failure:failure];
            break;
            
        default:
            return nil;
            break;
    }
}

@end
