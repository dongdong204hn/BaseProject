//
//  NIPJSExportDetail.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/21.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSExportDetail.h"

@implementation NIPJSExportDetail

- (instancetype)initWithExportInfo:(NSDictionary *)exportDetail {
    self = [super init];
    if (self) {
        self.showMethod = exportDetail[@"showMethod"];
        self.realMethod = exportDetail[@"realMethod"];
    }
    return self;
}


@end
