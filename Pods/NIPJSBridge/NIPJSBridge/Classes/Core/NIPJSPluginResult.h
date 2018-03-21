//
//  NIPJSPluginResult.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, NIPJSCommandStatus) {
    NIPJSCommandStatus_NO_RESULT = 0,
    NIPJSCommandStatus_OK,
    NIPJSCommandStatus_CLASS_NOT_FOUND_EXCEPTION,
    NIPJSCommandStatus_ILLEGAL_ACCESS_EXCEPTION,
    NIPJSCommandStatus_INSTANTIATION_EXCEPTION,
    NIPJSCommandStatus_MALFORMEDURL_EXCEPTION,
    NIPJSCommandStatus_IO_EXCEPTION,
    NIPJSCommandStatus_INVALID_ACTION,
    NIPJSCommandStatus_JSON_EXCEPTION,
    NIPJSCommandStatus_ERROR
};


/**
 * @class NIPJSPluginResult
 * 封装native执行结果
 */
@interface NIPJSPluginResult : NSObject

@property (nonatomic, strong, readonly) NSNumber *status;
@property (nonatomic, strong, readonly) id message;

+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                        messageAsString:(NSString *)theMessage;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                         messageAsArray:(NSArray *)theMessage;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                           messageAsInt:(int)theMessage;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                        messageAsDouble:(double)theMessage;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                          messageAsBool:(BOOL)theMessage;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                    messageAsDictionary:(NSDictionary *)theMessage;
+ (NIPJSPluginResult *)resultWithStatus:(NIPJSCommandStatus)statusOrdinal
                   messageToErrorObject:(int)errorCode;


/**
 * 直接封装Native处理结果
 */
- (NSString *)argumentsAsJSON;


/**
 * 将处理状态，和结果一起通过JSON形式封装；
 */
- (NSString *)toJSONString;


/**
 * 将处理结果封装成一个JS执行字符串
 */
- (NSString *)toJSCallbackString:(NSString *)callbackId;


@end
