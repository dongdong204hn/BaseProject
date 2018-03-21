//
//  UIDevice+URS.m
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "UIDevice+URS.h"
#import <AdSupport/AdSupport.h>

static NSString *deviceMacaddress() {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }

    ifm = (struct if_msghdr *) buf;
    sdl = (struct sockaddr_dl *) (ifm + 1);
    ptr = (unsigned char *) LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];

    free(buf);
    return outstring;
}

static NSString *randomMacaddress() {
    srandom([[NSDate date] timeIntervalSince1970]);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", (Byte) random(), (Byte) random(), (Byte) random(), (Byte) random(), (Byte) random(), (Byte) random()];
    return outstring;
}

@implementation UIDevice (URS)

#pragma mark MAC addy

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *)urs_macaddress
{
    static NSString *macAddress = nil;
    if (macAddress == nil) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            macAddress = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        } else {
            macAddress = deviceMacaddress();
        }
        if (macAddress == nil) {
            macAddress = randomMacaddress();
        }
    }
    return macAddress;
}


- (NSString *)urs_uniqueID
{
    if (NSClassFromString(@"ASIdentifierManager")) {
        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    } else {
        NSString *macAddress = deviceMacaddress();
        if (!macAddress) {
            macAddress = randomMacaddress();
        }
        return macAddress;
    }
}

@end
