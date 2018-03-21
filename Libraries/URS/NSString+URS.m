//
//  NSString+URS.m
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import "NSString+URS.h"
#import "URSARC.h"
#import "NSData+URS.h"

@implementation NSString (URS)

- (NSString *)urs_URLEncodedString
{
    NSString *result = (URS_BRIDGE_TRANSFER NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (URS_BRIDGE CFStringRef)self,
                                                                                             NULL,
                                                                                             CFSTR("!*'()^;:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8);
	return URS_AUTORELEASE(result);
}

- (NSString*)urs_URLDecodedString
{
	NSString *result = (URS_BRIDGE_TRANSFER NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (URS_BRIDGE CFStringRef)self,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8);
	return URS_AUTORELEASE(result);
}

- (NSString *)urs_md5 {
    const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *returnHashSum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [returnHashSum appendFormat:@"%02x", result[i]];
    }
	return returnHashSum;
}

-(unichar)urs_StringToASCIIChar:(NSString *)str{
    if ([str length] < 2) {
        return 0;
    }
    unichar one = [str characterAtIndex:0];
    unichar two = [str characterAtIndex:1];
    if(('0'<=one) && (one<='9')) {
        one=one-'0';
    }
    if(('a'<=one) && (one<='z')) {
        one=one-'a'+10;
    }
    if(('A'<=one) && (one<='Z')) {
        one=one-'A'+10;
    }
    if(('0'<=two) && (two<='9')) {
        two=two-'0';
    }
    if(('a'<=two) && (two<='z')) {
        two=two-'a'+10;
    }
    if(('A'<=two) && (two<='Z')) {
        two=two-'A'+10;
    }
    return one*16+two;
}

-(NSData *)urs_base16Data {
    if ([self length]%2 != 0) {
        return nil;
    }
    unsigned char key[[self length]/2+1];
    bzero(key, [self length]/2+1);
    for (int i=0; i<[self length]/2; i++) {
        NSString *str = [self substringWithRange:NSMakeRange(2*i, 2)];
        key[i] = [self urs_StringToASCIIChar:str];
    }
    return [NSData dataWithBytes:key length:[self length]/2];
}

- (NSInteger)urs_letterCount {
    NSInteger letterCount = 0;
    for (NSUInteger i=0; i<self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if ( (c>='a'&&c<='z')||(c>='A'&&c<='Z')) {
            letterCount++;
        }
    }
    return letterCount;
}

- (NSInteger)urs_numCount {
    NSInteger numCount = 0;
    for (NSUInteger i=0; i<self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if (c>='0'&&c<='9') {
            numCount++;
        }
    }
    return numCount;
}

@end
