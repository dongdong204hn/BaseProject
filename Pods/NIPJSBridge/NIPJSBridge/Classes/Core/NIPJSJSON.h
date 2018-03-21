//
//  NIPJSJSON.h
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NIPJSBridgeJSONSerializing)

- (NSString *)cdv_JSONString;

@end


@interface NSDictionary (NIPJSBridgeJSONSerializing)

- (NSString *)cdv_JSONString;

@end


@interface NSString (NIPJSBridgeJSONSerializing)

- (id)cdv_JSONObject;

@end
