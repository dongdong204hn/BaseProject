//
//  NIPJSInvokedURLCommand.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/14.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSInvokedURLCommand.h"

@interface NIPJSInvokedURLCommand ()

@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic, strong) NSString *pluginShowMethod;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *JSONParams;


@end;

@implementation NIPJSInvokedURLCommand


+ (NIPJSInvokedURLCommand *)commandFromJSON:(NSArray *)JSONEntity
{
    return [[NIPJSInvokedURLCommand alloc] initWithJSON:JSONEntity];
}


- (instancetype)initWithJSON:(NSArray *)JSONEntity {
    if (JSONEntity.count < 5) {
        return nil;
    }
    NSString *callbackId = JSONEntity[0] == [NSNull null] ? nil : JSONEntity[0];
    NSString *className = JSONEntity[1];
    NSString *methodName = JSONEntity[2];
    NSMutableArray *arguments = JSONEntity[3];
    NSArray *arr_jsonParams = JSONEntity[3];
    NSMutableDictionary *jsonParams = nil;
    if (arr_jsonParams && arr_jsonParams.count > 0) {
        jsonParams = [arr_jsonParams objectAtIndex:0];
    } else {
        jsonParams = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    return [self initWithCallbackId:callbackId
                          className:className
                         methodName:methodName
                          arguments:arguments
                      andJSONParams:jsonParams];
}

- (instancetype)initWithCallbackId:(NSString *)callbackId
                         className:(NSString *)className
                        methodName:(NSString *)methodName
                         arguments:(NSArray *)arguments
                     andJSONParams:(NSDictionary *)JSONParam {
    self = [super init];
    if (self != nil) {
        _callbackId = callbackId;
        _pluginName = className;
        _pluginShowMethod = methodName;
        _arguments = arguments;
        _JSONParams = JSONParam;
    }
    return self;
}


#pragma mark - 获取JSON参数

- (id)JSONParamForkey:(NSString *)key {
    return [self JSONParamForkey:key withDefault:@""];
}

- (id)JSONParamForkey:(NSString *)key withDefault:(id)defaultValue {
    return [self JSONParamForkey:key withDefault:defaultValue andClass:nil];
}


- (id)JSONParamForkey:(NSString *)key withDefault:(id)defaultValue andClass:(Class)aClass {
    id JSONValue = [_JSONParams objectForKey:[key lowercaseString]];
    if (JSONValue == nil || JSONValue == [NSNull null]) {
        return defaultValue;
    }
    
    if (aClass != nil && ![JSONValue isKindOfClass:aClass]) {
        JSONValue = defaultValue;
    }
    
    return JSONValue;
}


#pragma mark - 获取Array参数

- (id)argumentAtIndex:(NSUInteger)index {
    return [self argumentAtIndex:index withDefault:nil];
}


- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue {
    return [self argumentAtIndex:index withDefault:defaultValue andClass:nil];
}


- (id)argumentAtIndex:(NSUInteger)index withDefault:(id)defaultValue andClass:(Class)aClass {
    if (index >= [_arguments count]) {
        return defaultValue;
    }
    id ret = [_arguments objectAtIndex:index];
    if (ret == [NSNull null]) {
        ret = defaultValue;
    }
    if ((aClass != nil) && ![ret isKindOfClass:aClass]) {
        ret = defaultValue;
    }
    return ret;
}


@end
