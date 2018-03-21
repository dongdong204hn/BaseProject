//
//  NIPKeychain.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPKeychain.h"
#import <Security/Security.h>

@implementation NIPKeychain

+ (NSMutableDictionary *)createKeychainQuery:(NSString *)identifier{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            identifier,(__bridge_transfer id)kSecAttrService,
            identifier,(__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

+ (BOOL)saveKeychain:(id)data forIdentifier:(NSString *)identifier{
    if (!data) {
        return NO;
    }
    
    NSMutableDictionary *dic = [self createKeychainQuery:identifier];
    [dic setObject:(__bridge_transfer id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [dic setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    OSStatus status;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)dic, (CFTypeRef *)&keyData) == noErr) {
        NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
        [updateDictionary setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
        [dic removeObjectForKey:(__bridge_transfer id)kSecReturnData];
        [dic removeObjectForKey:(__bridge_transfer id)kSecMatchLimit];
        status = SecItemUpdate((__bridge CFDictionaryRef)dic,
                               (__bridge CFDictionaryRef)updateDictionary);
    } else {
        [dic removeObjectForKey:(__bridge_transfer id)kSecReturnData];
        [dic removeObjectForKey:(__bridge_transfer id)kSecMatchLimit];
        [dic setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
        status = SecItemAdd((__bridge CFDictionaryRef)dic, NULL);
    }
    
    if (status == errSecSuccess) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)updateKeychain:(id)data forIdentifier:(NSString *)identifier{
    NSMutableDictionary *searchDictionary = [self createKeychainQuery:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    [updateDictionary setObject:data forKey:(__bridge_transfer id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    
    if (searchDictionary) {
        CFRelease((__bridge CFTypeRef)(searchDictionary));
    }
    if (updateDictionary) {
        CFRelease((__bridge CFTypeRef)(updateDictionary));
    }
    
    return NO;
}

+ (id)findKeychain:(NSString *)identifier{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self createKeychainQuery:identifier];
    [keychainQuery setObject:(__bridge_transfer id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", identifier, e);
        } @finally {
        }
    }
    return ret;
}

+ (void)deleteKeychain:(NSString *)indentify{
    NSMutableDictionary *keychainQuery = [self createKeychainQuery:indentify];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}


@end
