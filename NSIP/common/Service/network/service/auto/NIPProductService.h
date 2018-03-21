//
//  NIPProductService.h
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseService.h"

@class NIPBaseRequest;

@class NIPPartnerGoodsResponse;

@interface NIPProductService : NIPBaseService

+ (instancetype)sharedService;

/**
 * 获取交易所产品信息
 */
- (NIPBaseRequest *)queryDefaultPartnerGoodsOnComplete:(void (^)(NIPPartnerGoodsResponse* response))onComplete;

@end
