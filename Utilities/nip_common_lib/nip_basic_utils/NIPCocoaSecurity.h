//
//  NIPCocoaSecurity.h
//  NSIP
//
//  Created by 赵松 on 16/12/14.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - CocoaSecurityResult
@interface CocoaSecurityResult : NSObject

@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;
@property (strong, nonatomic, readonly) NSString *hex;
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;

- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length;

@end


#pragma mark - CocoaSecurity
//! 封装多种加密算法
@interface NIPCocoaSecurity : NSObject
#pragma mark - AES Encrypt
+ (CocoaSecurityResult *)aesEncrypt:(NSString *)data key:(NSString *)key;
+ (CocoaSecurityResult *)aesEncrypt:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv;
+ (CocoaSecurityResult *)aesEncrypt:(NSString *)data key:(NSData *)key iv:(NSData *)iv;
+ (CocoaSecurityResult *)aesEncryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
#pragma mark AES Decrypt
+ (CocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSString *)key;
+ (CocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv;
+ (CocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSData *)key iv:(NSData *)iv;
+ (CocoaSecurityResult *)aesDecryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;

#pragma mark - MD5
+ (CocoaSecurityResult *)md5:(NSString *)hashString;
+ (CocoaSecurityResult *)md5WithData:(NSData *)hashData;
#pragma mark HMAC-MD5
+ (CocoaSecurityResult *)hmacMd5:(NSString *)hashString hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacMd5WithData:(NSData *)hashData hmacKey:(NSString *)key;

#pragma mark - SHA
+ (CocoaSecurityResult *)sha1:(NSString *)hashString;
+ (CocoaSecurityResult *)sha1WithData:(NSData *)hashData;
+ (CocoaSecurityResult *)sha224:(NSString *)hashString;
+ (CocoaSecurityResult *)sha224WithData:(NSData *)hashData;
+ (CocoaSecurityResult *)sha256:(NSString *)hashString;
+ (CocoaSecurityResult *)sha256WithData:(NSData *)hashData;
+ (CocoaSecurityResult *)sha384:(NSString *)hashString;
+ (CocoaSecurityResult *)sha384WithData:(NSData *)hashData;
+ (CocoaSecurityResult *)sha512:(NSString *)hashString;
+ (CocoaSecurityResult *)sha512WithData:(NSData *)hashData;
#pragma mark HMAC-SHA
+ (CocoaSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha1WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha224:(NSString *)hashString hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha224WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha256:(NSString *)hashString hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha256WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha384:(NSString *)hashString hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha384WithData:(NSData *)hashData hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha512:(NSString *)hashString hmacKey:(NSString *)key;
+ (CocoaSecurityResult *)hmacSha512WithData:(NSData *)hashData hmacKey:(NSString *)key;

#pragma mark DES
+ (NSString *)generateStamp;
+ (NSData *)encyptPostData:(NSData *)data withStamp:(NSString*)stamp;
+ (NSData *)decryptPostData:(NSData*)encryptData withStamp:(NSString*)stamp;

#pragma mark XXTEA
+ (NSString *)encryptXXTEA:(NSString *)data withKey:(NSString *)key;
+ (NSString *)decryptXXTEA:(NSString *)string withKey:(NSString *)key;

@end


#pragma mark - CocoaSecurityEncoder
@interface CocoaSecurityEncoder : NSObject
- (NSString *)base64:(NSData *)data;
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower;
@end


#pragma mark - CocoaSecurityDecoder
@interface CocoaSecurityDecoder : NSObject
- (NSData *)base64:(NSString *)data;
- (NSData *)hex:(NSString *)data;
@end
