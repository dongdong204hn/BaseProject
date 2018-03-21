//
//  NIPPartnerGoodsResponse.m
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPPartnerGoodsResponse.h"
#import "NIPWatchItem.h"

@implementation NIPPartnerGoodsResponse

+ (NSArray*)createWithJSONArray:(NSArray*)array {
    if (!array | [array isKindOfClass:[NSNull class]]) return nil;
    NSMutableArray *objectArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NIPPartnerGoodsResponse *object = [[NIPPartnerGoodsResponse alloc] initWithJSON:dict];
        if (object) [objectArray addObject:object];
    }
    return objectArray;
}

+ (instancetype)createWithJSON:(NSDictionary*)dict {
    return [[self alloc] initWithJSON:dict];
}

- (id)initWithJSON:(NSDictionary*)dict
{
    if (!dict | [dict isKindOfClass:[NSNull class]]) return nil;
    
    if (self =[super initWithJSON:dict]) {
        self.ret = [NIPWatchItem createWithJSONArray:dict[@"ret"]];
    }
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    if (self.ret) [dict setObject:self.ret forKey:@"ret"];
    return dict;
}

- (NSString*)description {
    return [[self toDictionary] description];
}


@end
