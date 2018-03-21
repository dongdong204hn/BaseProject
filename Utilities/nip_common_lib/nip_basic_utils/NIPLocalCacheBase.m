//
//  NIPLocalCacheBase.m
//  NSIP
//
//  Created by 赵松 on 16/12/5.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPLocalCacheBase.h"

@interface NIPLocalCacheBase()

@property (nonatomic, strong) id cachedObjects;
@property (nonatomic, assign) NIPLocalCacheType cacheType;

@end

@implementation NIPLocalCacheBase

+ (instancetype)dictionaryCache {
    NIPLocalCacheBase *cache = [NIPLocalCacheBase new];
    cache.cacheType = NIPLocalCacheTypeDictionary;
    return cache;
}

+ (instancetype)arrayCache {
    NIPLocalCacheBase *cache = [NIPLocalCacheBase new];
    cache.cacheType = NIPLocalCacheTypeArray;
    return cache;
}

- (id)init {
    if (self=[super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        self.cacheType = NIPLocalCacheTypeArray;
        self.cacheLimitCount = NSIntegerMax;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationBackground:(NSNotification*)note {
    [self saveObject:_cachedObjects toFile:self.fileName];
}

- (void)saveObject:(id)object toFile:(NSString*)fileName {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/localCache"];
    [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:NULL error:NULL];
    fullPath = [fullPath stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:object toFile:fullPath];
}

- (id)loadObjectFromFile:(NSString*)fileName {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/localCache"];
    fullPath = [fullPath stringByAppendingPathComponent:fileName];
    id value = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    return value;
}


#pragma mark - Common Method
- (NSInteger)cacheObjectsCount{
    NSInteger rtnValue = 0;
    id cache = [self cachedObjects];
    SEL sel = @selector(count);
    if ([cache respondsToSelector:sel]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[cache methodSignatureForSelector:sel]];
        [invocation setSelector:sel];
        [invocation setTarget:cache];
        [invocation invoke];
        [invocation getReturnValue:&rtnValue];
    }
    return rtnValue;
}

- (id)cachedObjects {
    if (!_cachedObjects) {
        if (_cacheType == NIPLocalCacheTypeArray) {
            _cachedObjects = [NSMutableArray arrayWithArray:[self loadObjectFromFile:self.fileName]];
        } else if (_cacheType == NIPLocalCacheTypeDictionary) {
            _cachedObjects = [NSMutableDictionary dictionaryWithDictionary:[self loadObjectFromFile:self.fileName]];
        }
    }
    return _cachedObjects;
}

- (void)saveToFile {
    [self saveObject:_cachedObjects toFile:self.fileName];
}

- (void)removeAll
{
    NSString *fullPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/localCache"];
    fullPath = [fullPath stringByAppendingPathComponent:self.fileName];
    
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    
    _cachedObjects = nil;
}

- (void)removeObject:(NSObject*)object forKey:(NSString*)key {
    if (!_cachedObjects) {
        [self cachedObjects];
    }
    
    if (_cacheType == NIPLocalCacheTypeArray) {
        NSUInteger oldIndex = [_cachedObjects indexOfObject:object];
        if (oldIndex!=NSNotFound) {
            [_cachedObjects removeObjectAtIndex:oldIndex];
            [self saveObject:_cachedObjects toFile:self.fileName];
        }
    } else if (_cacheType == NIPLocalCacheTypeDictionary) {
        if (key.length && [_cachedObjects objectForKey:key]) {
            [_cachedObjects removeObjectForKey:key];
            [self saveObject:_cachedObjects toFile:self.fileName];
        }
    }
}


#pragma mark - NSArray Method
- (id)objectAtIndex:(NSUInteger)index {
    if ([[self cachedObjects] isKindOfClass:[NSArray class]]) {
        if (index < [self cacheObjectsCount] ) {
            return _cachedObjects[index];
        }
    }
    
    return nil;
}

- (void)addObject:(NSObject*)object {
    [self addObject:object forKey:nil];
}

- (void)removeObject:(NSObject*)object {
    [self removeObject:object forKey:nil];
}

- (void)removeObjects:(NSArray *)objects {
    for (id object in objects) {
        [self removeObject:object];
    }
}

- (void)replaceObject:(NSObject*)old withObject:(NSObject*)new {
    [self replaceObject:old withObject:new forKey:nil];
}


#pragma mark - NSDictionary Method
- (id)objectForKey:(NSString*)key {
    if ([[self cachedObjects] isKindOfClass:[NSDictionary class]]) {
        if (key.length) {
            return [_cachedObjects objectForKey:key];
        }
    }
    
    return nil;
}

- (void)addObject:(NSObject*)object forKey:(NSString*)key {
    if (!_cachedObjects) {
        [self cachedObjects];
    }
    if (_cacheType == NIPLocalCacheTypeArray) {
        NSUInteger oldIndex = [_cachedObjects indexOfObject:object];
        if (oldIndex!=NSNotFound) {
            [_cachedObjects removeObjectAtIndex:oldIndex];
        }
        [_cachedObjects insertObject:object atIndex:0];
        while ([self cacheObjectsCount] > self.cacheLimitCount) {
            [_cachedObjects removeLastObject];
        }
        [self saveObject:_cachedObjects toFile:self.fileName];
    } else if (_cacheType == NIPLocalCacheTypeDictionary) {
        if (key.length) {
            if ([_cachedObjects objectForKey:key]) {
                [_cachedObjects setObject:object forKey:key];
            } else {
                if ([self cacheObjectsCount] < self.cacheLimitCount) {
                    [_cachedObjects setObject:object forKey:key];
                } else { //数目已满时随机删除一个数据
                    [_cachedObjects removeObjectForKey:[[_cachedObjects allKeys] objectAtIndex:arc4random() % [self cacheObjectsCount]]];
                }
            }
            [self saveObject:_cachedObjects toFile:self.fileName];
        }
    }
}

- (void)removeObjectForKey:(NSString *)key {
    [self removeObject:nil forKey:key];
}

- (void)removeObjectForKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        [self removeObjectForKey:key];
    }
}

- (void)replaceObject:(NSObject*)old withObject:(NSObject*)new forKey:(NSString*)key {
    if (!_cachedObjects) {
        [self cachedObjects];
    }
    if (_cacheType == NIPLocalCacheTypeArray) {
        NSUInteger oldIndex = [_cachedObjects indexOfObject:old];
        if (oldIndex!=NSNotFound) {
            [_cachedObjects replaceObjectAtIndex:oldIndex withObject:new];
            [self saveObject:_cachedObjects toFile:self.fileName];
        } else {
            [self addObject:new];
        }
    } else if (_cacheType == NIPLocalCacheTypeDictionary) {
        [self addObject:new forKey:key];
    }
}

@end