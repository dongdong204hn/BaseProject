//
//  NIPPartnerGoodsResponse.h
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseResponse.h"
#import "NIPModelObject.h"

@interface NIPPartnerGoodsResponse : NIPBaseResponse <NIPModelObject>

@property(nonatomic,strong) NSArray *ret;

+ (NSArray*)createWithJSONArray:(NSArray*)array;

+ (instancetype)createWithJSON:(NSDictionary*)dict;

- (NSDictionary*)toDictionary;

@end
