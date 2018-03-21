//
//  NIPBaseResponse.m
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import "NIPBaseResponse.h"
#import "NIPCoderUtil.h"

@implementation NIPBaseResponse

+ (NSArray*)createWithJSONArray:(NSArray*)array {
    NSMutableArray *objectArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NIPBaseResponse *object = [[NIPBaseResponse alloc] initWithJSON:dict];
        if (object) [objectArray addObject:object];
    }
    return objectArray;
}

+ (instancetype)createWithJSON:(NSDictionary*)dict {
    return [[self alloc] initWithJSON:dict];
}

- (id)initWithJSON:(NSDictionary*)dict {
    if (dict==nil) return nil;
    
    if (self =[super init]) {
        self.retCode = [NIPCoderUtil integerFromDictionary:dict ofKey:@"retCode" defaultValue:0];
        self.retDesc = [NIPCoderUtil stringFromDictionary:dict ofKey:@"retDesc" defaultValue:@""];
    }
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(self.retCode) forKey:@"retCode"];
    [dict setObject:self.retDesc forKey:@"retDesc"];
    return dict;
}


@end
