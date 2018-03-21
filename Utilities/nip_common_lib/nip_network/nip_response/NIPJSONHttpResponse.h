//
//  NIPJSONHttpResponse.h
//  crowdfunding
//
//  Created by mateng on 15/8/17.
//  Copyright (c) 2015年 网易. All rights reserved.
//

#import "NIPHttpResponse.h"

@interface NIPJSONHttpResponse : NIPHttpResponse

@property(nonatomic,strong) id json; //原始json数据

@end
