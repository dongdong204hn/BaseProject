//
//  UIDevice+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "UIDevice+NIPBasicAdditions.h"
#import "NSString+NIPBasicAdditions.h"
#import <sys/utsname.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import "nip_macros.h"

@implementation UIDevice (NIPBasicAdditions)

+ (CGFloat)screenScale
{
    return [UIScreen mainScreen].scale;
}

+ (CGFloat)screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (BOOL)fourInchScreen
{
    return [UIScreen mainScreen].bounds.size.height > 480;
}

+ (NSInteger)systemMainVersion
{
    NSString *version = [UIDevice currentDevice].systemVersion;
    return version.integerValue;
}

+ (NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if (!platform) {
        platform = @"未知";
    }
    return platform;
}

+ (NSString *)getProcessorInfo {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)getDeviceName {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524/A1593)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586/A1589)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6S Plus (A1634/A1687/A1699)";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6S (A1633/A1688/A1700)";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE (A1723/A1662/A1724)";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7（A1660/A1779/A1780)";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus（A1661/A1785/A1786)";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1 (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2 (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3 (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4 (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5 (A1421/A1509)";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPod Touch 6 (A1574)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1 (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395 Wi-Fi)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396 GSM)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397 CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip Wi-Fi)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1 (A1432 Wi-Fi)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1 (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1 (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416 Wi-Fi)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403 Wi-Fi + LTE Verizon)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430 Wi-Fi + LTE AT＆T)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458 Wi-Fi)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474 Wi-Fi)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475 Wi-Fi + LTE)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476 Rev)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2 (A1489 Wi-Fi)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2 (A1490 Wi-Fi + LTE)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2 (A1491)";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 3 (A1599 Wi-Fi)";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 3 (A1600)";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 3 (A1601)";
    
    if ([platform isEqualToString:@"iPad5,1"])   return @"iPad Mini 4 (A1538 Wi-Fi)";
    if ([platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4 (A1550 Wi-Fi + LTE)";
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2 (A1566 Wi-Fi)";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2 (A1567 Wi-Fi + LTE)";
    
    if ([platform isEqualToString:@"iPad6,3"])   return @"iPad Pro (A1673 9.7英寸 Wi-Fi)";
    if ([platform isEqualToString:@"iPad6,4"])   return @"iPad Pro (A1674/A1675 9.7英寸 Wi-Fi + LTE)";
    if ([platform isEqualToString:@"iPad6,7"])   return @"iPad Pro (A1584 12.9英寸 Wi-Fi)";
    if ([platform isEqualToString:@"iPad6,8"])   return @"iPad Pro (A1652 12.9英寸 Wi-Fi + LTE)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

+ (NSString *)getChannelString {
    static NSString *cString = nil;
    if(cString) {
        return cString;
    }
#ifdef NETEASE_CHANNEL
    cString =  @"tgwios";
#else
    cString =  @"appstore";
#endif
    return cString;
}

#pragma mark - Private Methods



@end
