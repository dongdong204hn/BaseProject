//
//  NIPJSPluginResult.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPluginResult.h"
#import "NIPJSJSON.h"


@implementation NIPJSPluginResult


#pragma mark - life cycle

- (instancetype)init {
    return [self initWithStatus:NIPJSCommandStatus_NO_RESULT message:nil];
}


- (instancetype)initWithStatus:(NIPJSCommandStatus)statusOrdinal message:(id)theMessage
{
    self = [super init];
    if (self) {
        _status = [NSNumber numberWithInt:statusOrdinal];
        _message = theMessage;
    }
    return self;
}


#pragma mark - 封装返回数据

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
{
    return [[self alloc] initWithStatus:statusOrdinal message:nil];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                        messageAsString:(NSString *)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal
                                message:theMessage];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                         messageAsArray:(NSArray *)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal
                                message:theMessage];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                           messageAsInt:(int)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal
                                message:[NSNumber numberWithInt:theMessage]];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                        messageAsDouble:(double)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal
                                message:[NSNumber numberWithDouble:theMessage]];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                          messageAsBool:(BOOL)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal
                                message:[NSNumber numberWithBool:theMessage]];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                    messageAsDictionary:(NSDictionary *)theMessage
{
    return [[self alloc] initWithStatus:statusOrdinal
                                message:theMessage];
}

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                   messageToErrorObject:(int)errorCode
{
    NSDictionary *errDict = @{ @"code" : [NSNumber numberWithInt:errorCode] };
    return [[self alloc] initWithStatus:statusOrdinal
                                message:errDict];
}


#pragma mark - 将返回数据统一转化成JSON

- (NSString *)argumentsAsJSON {
    id arguments = (self.message == nil ? [NSNull null] : self.message);
    
    //通过Array封装成JSON数组，然后去掉两头的括号
    NSArray *argumentsWrappedInArray = [NSArray arrayWithObject:arguments];
    NSString *argumentsJSON = [argumentsWrappedInArray cdv_JSONString];
    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];
    return argumentsJSON;
}


- (NSString *)toJSONString
{
    NSDictionary *dict = [NSDictionary
                          dictionaryWithObjectsAndKeys:self.status, @"status",
                          self.message ? self.message : [NSNull null], @"message", nil];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *resultString = nil;
    if (error != nil) {
        NSLog(@"toJSONString error: %@", [error localizedDescription]);
    } else {
        resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return resultString;
}


#pragma mark - 将处理结果封装成执行字符串

- (NSString *)toJSCallbackString:(NSString *)callbackId
{
    NSString *successCB = @"";
    NSString *argumentsAsJSON = [self argumentsAsJSON];
    argumentsAsJSON = [argumentsAsJSON stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([callbackId intValue] > 0) {
        successCB = [successCB stringByAppendingFormat:@"mapp.execGlobalCallback(%d,'%@');",
                     [callbackId intValue], argumentsAsJSON];
    } else {
        successCB =
        [successCB stringByAppendingFormat:@"window.%@('%@');", callbackId, argumentsAsJSON];
    }
    
    return successCB;
}


@end
