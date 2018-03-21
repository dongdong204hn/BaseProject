//
//  NTHttpsValidator.h
//  trainTicket
//
//  Created by zhao on 14-6-5.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIPHttpsValidator;

@protocol NTHttpsValidatorDelegate <NSObject>

@optional

- (void)validateHttpsHostStringSuccess:(NSString *)hostString;

@end

/**
 *  HTTPS请求host验证器，使用方法+ (instancetype)shareValidator获取单例
 */
@interface NIPHttpsValidator : NSObject

@property (nonatomic,assign) id<NTHttpsValidatorDelegate> delegate;

+ (instancetype)shareValidator;

- (void)validateUntrustHostArray;
- (void)validateUntrustHostString:(NSString *)hostString;

- (void)addTrustHostString:(NSString *)hostString;

- (BOOL)isHostStringBeTrusted:(NSString *)hostString;

@end
