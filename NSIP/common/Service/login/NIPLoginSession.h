//
//  NIPLoginSession.h
//  NSIP
//
//  Created by Eric on 16/11/2.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPLoginSession : NSObject

@property (nonatomic, strong) NSString *loginID;
@property (nonatomic, strong) NSString *loginToken;


+ (instancetype)sharedSession;

- (BOOL)hasLoginURS;
- (void)logout;

@end
