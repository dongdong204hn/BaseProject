//
//  URSRequest.h
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URSARC.h"

@class URSRequest;

@protocol URSRequestDelegate <NSObject>
- (void)request:(URSRequest *)request success:(NSString *)responseString;

- (void)request:(URSRequest *)request fail:(NSError *)error;
@end

@interface URSRequest : NSObject

@property (nonatomic, URS_WEAK) id <URSRequestDelegate> delegate;

+ (URSRequest *)reqquest;

+ (NSString *)paramatersWithDictionary:(NSDictionary *)params;

- (void)postWithUrl:(NSString *)url
           andParam:(NSDictionary *)params;

- (void)cancel;
@end
