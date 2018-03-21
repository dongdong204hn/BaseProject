//
//  NSDictionary+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NSDictionary+NIPBasicAdditions.h"
#import "NSString+NIPBasicAdditions.h"

@implementation NSDictionary (NIPBasicAdditions)

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(boolValue)]) {
        return [(id)object boolValue];
    }
    return defaultValue;
}

- (int)intForKey:(NSString *)key defaultValue:(int)defaultValue
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(intValue)]) {
        return [(id)object intValue];
    }
    return defaultValue;
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(integerValue)]) {
        return [(id)object integerValue];
    }
    return defaultValue;
}

- (long)longForKey:(NSString *)key defaultValue:(long)defaultValue
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(longValue)]) {
        return [(id)object longValue];
    }
    return defaultValue;
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(doubleValue)]) {
        return [(id)object doubleValue];
    }
    return defaultValue;
}

- (float)floatForKey:(NSString *)key defaultValue:(float)defaultValue
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(floatValue)]) {
        return [(id)object floatValue];
    }
    return defaultValue;
}

- (NSString *)stringForKey:(NSString *)key
{
    NSObject *object = [self objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return @"";
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    }
    return [NSString stringWithFormat:@"%@",object];
}

- (id)validObjectForKey:(NSString *)key
{
    NSObject *object = [self objectForKey:key];
    
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    NSObject *object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSArray class]]) {
        return (NSArray *)object;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)object allValues];
    }
    return nil;
}

- (NSDate *)dateForKey:(NSString *)key
{
    NSString *object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        static NSDateFormatter *formater = nil;
        
        if (!formater) {
            formater =[[NSDateFormatter alloc] init];
            [formater setLocale:[NSLocale currentLocale]];
        }
        
        if (object.length == @"yyyy-MM-dd HH:mm".length) {
            [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
        } else if (object.length == @"yyyy-MM-dd HH:mm:ss".length) {
            [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        
        return [formater dateFromString:object];
    }
    
    if ([object isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[object integerValue]];
    }
    return nil;
}

- (NSString *)convertToQueryString
{
    return [[self getQueryStringComponentsEncoded:YES] componentsJoinedByString:@"&"];
}

- (NSString *)convertToQueryStringWithoutURLEncoding
{
    return [[self getQueryStringComponentsEncoded:NO] componentsJoinedByString:@"&"];
}

- (NSArray *)getQueryStringComponentsEncoded:(BOOL)encoded
{
    return [self getQueryStringComponentsFromKey:nil andValue:self withURLEncoded:encoded];
}

- (NSArray *)getQueryStringComponentsFromKey:(NSString *)key andValue:(id)value withURLEncoded:(BOOL)encoded
{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:[self getQueryStringComponentsFromKey:key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey andValue:nestedValue withURLEncoded:encoded]];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:[self getQueryStringComponentsFromKey:[NSString stringWithFormat:@"%@[]", key] andValue:nestedValue withURLEncoded:encoded]];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:[self getQueryStringComponentsFromKey:key andValue:obj withURLEncoded:encoded]];
        }
    } else {
        NSString *queryStringComponent;
        if (!value || [value isEqual:[NSNull null]]) {
            if (encoded) {
                queryStringComponent = [[value description] URLEncodedStringLeaveUnescapedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
            } else {
                queryStringComponent = [value description];
            }
        } else {
            if (encoded) {
                NSString *encodedKey = [[key description] URLEncodedStringLeaveUnescapedCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                NSString *encodedValue = [[value description] URLEncodedString];
                queryStringComponent = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
            } else {
                queryStringComponent = [NSString stringWithFormat:@"%@=%@", [key description], [value description]];
            }
        }
        [mutableQueryStringComponents addObject:queryStringComponent];
    }
    return [mutableQueryStringComponents copy];
}

- (NSDictionary *)removeEmptyString {
    if (!self) {
        return nil;
    }
    
    NSMutableDictionary *newDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    NSMutableArray *keysToBeRemovedArray = [NSMutableArray array];
    for (NSString *key in newDictionary.allKeys) {
        if (0 == [[newDictionary stringForKey:key] length]) {
            [keysToBeRemovedArray addObject:key];
        }
    }
    for (NSString *key in keysToBeRemovedArray) {
        [newDictionary removeObjectForKey:key];
    }
    return newDictionary;
}

@end


#pragma mark - NSMutableDictionary

@implementation NSMutableDictionary (NTBasicAdditions)

- (void)setValidObject:(id)anObject forKey:(id)aKey
{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)setInteger:(NSInteger)value forKey:(id)key
{
    [self setValue:[NSNumber numberWithInteger:value]
            forKey:key];
}

- (void)setDouble:(double)value forKey:(id)key
{
    [self setValue:[NSNumber numberWithDouble:value] forKey:key];
}


@end
