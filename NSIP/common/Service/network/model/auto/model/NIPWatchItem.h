//
//  NIPWatchItem.h
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIPModelObject.h"

@interface NIPWatchItem : NSObject <NIPModelObject,NSCoding,NSCopying>

@property (nonatomic, copy) NSString *partnerId;
@property (nonatomic, copy) NSString *partnerName; //交易所名称
@property (nonatomic, copy) NSString *partnerDesc; //交易所全称
@property (nonatomic, copy) NSString *goodsId;
@property (nonatomic, copy) NSString *goodsName; // 产品名称
@property (nonatomic, assign) BOOL enableTrade;  // 是否可被交易
@property (nonatomic, assign) NSInteger disp;    // 我也不知道这是啥


+ (NSArray*)createWithJSONArray:(NSArray*)array;

+ (instancetype)createWithJSON:(NSDictionary*)dict;

- (NSDictionary*)toDictionary;

@end
