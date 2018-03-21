//
//  NIPJSInvokedURLCommand.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/14.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class NIPJSInvokedURLCommand
 * 解析URL传进来的Command命令和参数
 */
@interface NIPJSInvokedURLCommand : NSObject

@property (nonatomic, strong, readonly) NSString *callbackId;
@property (nonatomic, strong, readonly) NSString *pluginName;
@property (nonatomic, strong, readonly) NSString *pluginShowMethod;
@property (nonatomic, strong, readonly) NSArray *arguments;
@property (nonatomic, strong, readonly) NSDictionary *JSONParams;


+ (NIPJSInvokedURLCommand *)commandFromJSON:(NSArray *)JSONEntity;


/**
 * 存储或者获取通过JSON传进来的参数
 */
- (instancetype)initWithCallbackId:(NSString *)callbackId
                         className:(NSString *)className
                        methodName:(NSString *)methodName
                         arguments:(NSArray *)arguments
                     andJSONParams:(NSDictionary *)JSONParam;

- (id)JSONParamForkey:(NSString *)key;
- (id)JSONParamForkey:(NSString *)key withDefault:(id)defaultValue;
- (id)JSONParamForkey:(NSString *)key withDefault:(id)defaultValue andClass:(Class)aClass;


/**
 * 存储或者获取通过Array传进来的参数
 */
- (id)argumentAtIndex:(NSUInteger)index;
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue;
- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass;

@end
