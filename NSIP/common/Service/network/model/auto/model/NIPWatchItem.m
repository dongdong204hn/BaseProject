//
//  NIPWatchItem.m
//  NSIP
//
//  Created by Eric on 2016/12/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPWatchItem.h"
#import "NIPCoderUtil.h"

@implementation NIPWatchItem


+ (NSArray*)createWithJSONArray:(NSArray*)array {
    if (!array | [array isKindOfClass:[NSNull class]]) return nil;
    NSMutableArray *objectArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NIPWatchItem *object = [[NIPWatchItem alloc] initWithJSON:dict];
        if (object)
            [objectArray addObject:object];
    }
    return objectArray;
}

+ (instancetype)createWithJSON:(NSDictionary*)dict {
    return [[self alloc] initWithJSON:dict];
}

- (id)initWithJSON:(NSDictionary*)dict
{
    if (!dict | [dict isKindOfClass:[NSNull class]]) return nil;
    
    if (self =[super init]) {
        self.goodsName = [NIPCoderUtil stringFromDictionary:dict ofKey:@"goodsName" defaultValue:@""];
        self.goodsId = [NIPCoderUtil stringFromDictionary:dict ofKey:@"goodsId" defaultValue:@""];
        self.partnerId = [NIPCoderUtil stringFromDictionary:dict ofKey:@"partnerId" defaultValue:@""];
        self.partnerName = [NIPCoderUtil stringFromDictionary:dict ofKey:@"partnerName" defaultValue:@""];
        self.partnerDesc = [NIPCoderUtil stringFromDictionary:dict ofKey:@"partnerDesc" defaultValue:@""];
        self.enableTrade = [NIPCoderUtil boolFromDictionary:dict ofKey:@"enableTrade" defaultValue:NO];
        self.disp = [NIPCoderUtil integerFromDictionary:dict ofKey:@"disp" defaultValue:0];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ENCODE_BASIC_PROPERTY(disp,Int64);
    ENCODE_BASIC_PROPERTY(enableTrade, Bool);
    ENCODE_OBJECT_PROPERTY(goodsName);
    ENCODE_OBJECT_PROPERTY(goodsId);
    ENCODE_OBJECT_PROPERTY(partnerName);
    ENCODE_OBJECT_PROPERTY(partnerId);
    ENCODE_OBJECT_PROPERTY(partnerDesc);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super init]) {
        DECODE_PROPERTY(disp,Int64);
        DECODE_PROPERTY(enableTrade,Bool);
        DECODE_PROPERTY(partnerId,Object);
        DECODE_PROPERTY(partnerName,Object);
        DECODE_PROPERTY(partnerDesc,Object);
        DECODE_PROPERTY(goodsId,Object);
        DECODE_PROPERTY(goodsName,Object);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    NIPWatchItem* copyObject = [[NIPWatchItem allocWithZone:zone] init];
    copyObject.goodsId = self.goodsId;
    copyObject.goodsName = self.goodsName;
    copyObject.partnerDesc = self.partnerDesc;
    copyObject.partnerName = self.partnerName;
    copyObject.partnerId = self.partnerId;
    copyObject.enableTrade = self.enableTrade;
    copyObject.disp = self.disp;
    return copyObject;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(self.enableTrade) forKey:@"enableTrade"];
    [dict setObject:@(self.disp) forKey:@"disp"];
    [dict setObject:self.goodsName?:@"" forKey:@"goodsName"];
    [dict setObject:self.goodsId?:@"" forKey:@"goodsId"];
    [dict setObject:self.partnerId?:@"" forKey:@"partnerId"];
    [dict setObject:self.partnerName?:@"" forKey:@"partnerName"];
    [dict setObject:self.partnerDesc?:@"" forKey:@"partnerDesc"];
    return dict;
}

- (NSString*)description {
    return [[self toDictionary] description];
}

@end
