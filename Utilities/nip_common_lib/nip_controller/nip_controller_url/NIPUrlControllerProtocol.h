//
//  NIPUrlControllerProtocol.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  支持url跳转的controller需要实现的Protocol
 */
@protocol NIPUrlControllerProtocol <NSObject>
@optional
- (BOOL)urlControllerPrepareWithParameter:(NSDictionary*)param;
- (BOOL)urlControllerShouldBePresented;

- (BOOL)urlControllerCanHanlePageRedirect:(NSString*)pageId;
- (UIViewController*)urlControllerHandlePageRedirect:(NSString*)pageId
                                       withParameter:(NSDictionary*)param
                                            animated:(BOOL)animated;
@end

