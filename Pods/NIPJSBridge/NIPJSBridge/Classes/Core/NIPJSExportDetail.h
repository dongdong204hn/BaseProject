//
//  NIPJSExportDetail.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/21.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @class NIPJSExportDetail
 * 对插件对外开放JSAPI调用接口和插件native方法的对应
 */
@interface NIPJSExportDetail : NSObject

@property (strong, nonatomic) NSString *showMethod;  // JSAPI调用方法名
@property (strong, nonatomic) NSString *realMethod;  // 插件method名


/**
 * 根据传入的字典初始化exportDetail信息
 */
- (instancetype)initWithExportInfo:(NSDictionary *)exportDetail;

@end
