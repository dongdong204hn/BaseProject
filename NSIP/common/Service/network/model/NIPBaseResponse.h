//
//  NIPBaseResponse.h
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import "NIPModelHttpResponse.h"
#import "NIPModelObject.h"


@interface NIPBaseResponse : NIPModelHttpResponse<NIPModelObject>


@property (nonatomic, assign) NSInteger retCode;
@property (nonatomic, strong) NSString *retDesc;

+ (NSArray*)createWithJSONArray:(NSArray*)array;
+ (instancetype)createWithJSON:(NSDictionary*)dict;
- (id)initWithJSON:(NSDictionary*)dict;
- (NSDictionary*)toDictionary;

@end
