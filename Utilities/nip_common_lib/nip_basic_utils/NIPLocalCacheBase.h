//
//  NIPLocalCacheBase.h
//  NSIP
//
//  Created by 赵松 on 16/12/5.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NIPLocalCacheType) {
    NIPLocalCacheTypeError = 0,
    NIPLocalCacheTypeArray = 1, //default
    NIPLocalCacheTypeDictionary = 2,
};

@interface NIPLocalCacheBase : NSObject

@property(nonatomic) NSInteger cacheLimitCount;
@property(nonatomic) NSInteger cacheObjectsCount;
@property(nonatomic) NSString *fileName;

+ (instancetype)dictionaryCache;

+ (instancetype)arrayCache;

- (NIPLocalCacheType)cacheType;

#pragma mark - Common Method
- (id)cachedObjects;
- (void)removeAll;
- (void)saveToFile;

#pragma mark - Array Method
- (id)objectAtIndex:(NSUInteger)index;

- (void)addObject:(NSObject*)object;
- (void)removeObject:(NSObject*)object;
- (void)removeObjects:(NSArray*)objects;
- (void)replaceObject:(NSObject*)old withObject:(NSObject*)new;



#pragma mark - Dictionary Method
- (id)objectForKey:(NSString*)key;

- (void)addObject:(NSObject*)object forKey:(NSString*)key;
- (void)removeObjectForKey:(NSString*)key;
- (void)removeObjectForKeys:(NSArray*)keys;
- (void)replaceObject:(NSObject*)old withObject:(NSObject*)new  forKey:(NSString*)key;


@end
