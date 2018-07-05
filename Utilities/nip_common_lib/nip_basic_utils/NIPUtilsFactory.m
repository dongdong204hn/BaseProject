//
//  NIPUtilsFactory.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPUtilsFactory.h"
#import <sys/utsname.h>
#include <sys/sysctl.h>
#import "NIPKeychain.h"
#import "nip_macros.h"
#import "NIPLocalSettings.h"

static NSString * const kNipIdfa = @"kNipIdfa";
static NSString * const kNipIdfv = @"kNipIdfv";
static NSString * const kNipUuid = @"kNipUuid";

@implementation NIPUtilsFactory

+ (NSDecimalNumber *)decimalNumberFromDictionary:(NSDictionary *)dict ofKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    NSDecimalNumber *defaultp = [NSDecimalNumber decimalNumberWithString:defaultValue];
    NSObject *object = [dict valueForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultp;
    }
    
    if ([object isKindOfClass:[NSNumber class]]) {
        return (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[(NSNumber *)object doubleValue]];
    }
    return defaultp;
}

+ (NSString *)uuid
{
    NSString *uuid = nil;
    //#if (TARGET_OS_SIMULATOR) && DEBUG
    //    return @"debug_ios_simulator";
    //#else
    uuid = [NIPLocalSettings settings].uuid;
    if (NOT_EMPTY_STRING(uuid)) {
        return uuid;
    }
    uuid = [NIPKeychain findKeychain:kNipUuid];
    if (NOT_EMPTY_STRING(uuid)) {
        [NIPLocalSettings settings].uuid = uuid;
        return uuid;
    }
    uuid = [self generateUuid];
    [NIPLocalSettings settings].uuid = uuid;
    [NIPKeychain saveKeychain:uuid forIdentifier:kNipUuid];
    //#endif
    return uuid;
}

+ (NSString *)idfv
{
    NSString *idfv = nil;
    //#if (TARGET_OS_SIMULATOR) && DEBUG
    //    return @"debug_ios_simulator";
    //#else
    idfv = [NIPLocalSettings settings].idfv;
    if (NOT_EMPTY_STRING(idfv)) {
        return idfv;
    }
    idfv = [NIPKeychain findKeychain:kNipUuid];
    if (NOT_EMPTY_STRING(idfv)) {
        [NIPLocalSettings settings].uuid = idfv;
        return idfv;
    }
    idfv = [self generateIdfv];
    [NIPLocalSettings settings].idfv = idfv;
    [NIPKeychain saveKeychain:idfv forIdentifier:kNipIdfv];
    //#endif
    return idfv;
}

+ (NSString *)idfa
{
    NSString *idfa = nil;
    //#if (TARGET_OS_SIMULATOR) && DEBUG
    //    return @"debug_ios_simulator";
    //#else
    idfa = [NIPLocalSettings settings].idfa;
    if (NOT_EMPTY_STRING(idfa)) {
        return idfa;
    }
    idfa = [NIPKeychain findKeychain:kNipIdfa];
    if (NOT_EMPTY_STRING(idfa)) {
        [NIPLocalSettings settings].idfa = idfa;
        return idfa;
    }
    idfa = [self generateIdfa];
    [NIPLocalSettings settings].idfa = idfa;
    [NIPKeychain saveKeychain:idfa forIdentifier:kNipIdfa];
    //#endif
    return idfa;
}

+ (NSString *)generateIdfa {
    NSString *ifa = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifa = [advertisingIdentifier UUIDString];
    }
    return ifa;
}

+ (NSString *)generateIdfv {
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}

+ (NSString *)generateUuid {
    if(NSClassFromString(@"NSUUID")) { // only available in iOS >= 6.0
        return [[NSUUID UUID] UUIDString];
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
    return uuid;
}

+ (void)callPhoneNum:(NSString *)num {
    NSString *string = [NSString stringWithFormat:@"tel://%@",num];
    NSURL *url = [NSURL URLWithString:string];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                          message:@"您的设备不能拨打电话"
                                                       delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
        [alert show];
    }
}

@end
