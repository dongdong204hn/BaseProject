//
//  NIPProductService.m
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPProductService.h"

#import "NIPPartnerGoodsResponse.h"

@implementation NIPProductService


#pragma mark - lifecycle

+ (instancetype)sharedService {
    static NIPProductService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NIPProductService alloc] init];
    });
    return _sharedInstance;
}


#pragma mark - public methods

- (NIPBaseRequest *)queryDefaultPartnerGoodsOnComplete:(void (^)(NIPPartnerGoodsResponse* response))onComplete {
    NSMutableDictionary *param_ = [NSMutableDictionary dictionary];
    return [self requestPath:@"common/queryDefaultPartnerGoods" withParam:param_ forResponse:[NIPPartnerGoodsResponse class] onComplete:onComplete];
}

@end
