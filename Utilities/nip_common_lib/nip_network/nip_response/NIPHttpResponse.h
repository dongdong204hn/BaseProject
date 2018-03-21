//
//  NIPHttpResponse.h
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络请求的返回数据基类
 *  不同类型的网络请求会返回其子类对象
 */
@interface NIPHttpResponse : NSObject

@property(nonatomic,strong) NSError *error;
@property(nonatomic,strong) NSHTTPURLResponse *urlReponse;

- (instancetype)initWithError:(NSError*)error;

@end
