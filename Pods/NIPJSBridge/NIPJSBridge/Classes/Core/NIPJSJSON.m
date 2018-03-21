//
//  NIPJSJSON.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSJSON.h"
#import <Foundation/NSJSONSerialization.h>


@implementation NSArray (NIPJSBridgeJSONSerializing)

- (NSString *)cdv_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error != nil) {
        NSLog(@"NSArray JSONString error: %@", [error localizedDescription]);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end


@implementation NSDictionary (NIPJSBridgeJSONSerializing)

- (NSString *)cdv_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error != nil) {
        NSLog(@"NSDictionary JSONString error: %@", [error localizedDescription]);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end


@implementation NSString (NIPJSBridgeJSONSerializing)

- (id)cdv_JSONObject
{
    NSError *error = nil;
    id object =
    [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                    options:NSJSONReadingMutableContainers
                                      error:&error];
    
    if (error != nil) {
        NSLog(@"NSString JSONObject error: %@", [error localizedDescription]);
    }
    
    return object;
}

@end
