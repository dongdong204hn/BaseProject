//
//  NIPCocoaSecurity.m
//  NSIP
//
//  Created by 赵松 on 16/12/14.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPCocoaSecurity.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+NIPBasicAdditions.h"
#import "NSString+NIPBasicAdditions.h"
#import "NIPBase64Transcoder.h"

@implementation NIPCocoaSecurity

#pragma mark - AES Encrypt
// default AES Encrypt, key -> SHA384(key).sub(0, 32), iv -> SHA384(key).sub(32, 16)
+ (CocoaSecurityResult *)aesEncrypt:(NSString *)data key:(NSString *)key
{
    CocoaSecurityResult * sha = [self sha384:key];
    NSData *aesKey = [sha.data subdataWithRange:NSMakeRange(0, 32)];
    NSData *aesIv = [sha.data subdataWithRange:NSMakeRange(32, 16)];
    
    return [self aesEncrypt:data key:aesKey iv:aesIv];
}
#pragma mark AES Encrypt 128, 192, 256
+ (CocoaSecurityResult *)aesEncrypt:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv
{
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    NSData *aesKey = [decoder hex:key];
    NSData *aesIv = [decoder hex:iv];
    
    return [self aesEncrypt:data key:aesKey iv:aesIv];
}
+ (CocoaSecurityResult *)aesEncrypt:(NSString *)data key:(NSData *)key iv:(NSData *)iv
{
    return [self aesEncryptWithData:[data dataUsingEncoding:NSUTF8StringEncoding] key:key iv:iv];
}
+ (CocoaSecurityResult *)aesEncryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv
{
    // check length of key and iv
    if ([iv length] != 16) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of iv is wrong. Length of iv should be 16(128bits)"
                                     userInfo:nil];
    }
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 ) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          [iv bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Encrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}
#pragma mark - AES Decrypt
// default AES Decrypt, key -> SHA384(key).sub(0, 32), iv -> SHA384(key).sub(32, 16)
+ (CocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSString *)key
{
    CocoaSecurityResult * sha = [self sha384:key];
    NSData *aesKey = [sha.data subdataWithRange:NSMakeRange(0, 32)];
    NSData *aesIv = [sha.data subdataWithRange:NSMakeRange(32, 16)];
    
    return [self aesDecryptWithBase64:data key:aesKey iv:aesIv];
}
#pragma mark AES Decrypt 128, 192, 256
+ (CocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data hexKey:(NSString *)key hexIv:(NSString *)iv
{
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    NSData *aesKey = [decoder hex:key];
    NSData *aesIv = [decoder hex:iv];
    
    return [self aesDecryptWithBase64:data key:aesKey iv:aesIv];
}
+ (CocoaSecurityResult *)aesDecryptWithBase64:(NSString *)data key:(NSData *)key iv:(NSData *)iv
{
    CocoaSecurityDecoder *decoder = [CocoaSecurityDecoder new];
    return [self aesDecryptWithData:[decoder base64:data] key:key iv:iv];
}
+ (CocoaSecurityResult *)aesDecryptWithData:(NSData *)data key:(NSData *)key iv:(NSData *)iv
{
    // check length of key and iv
    if ([iv length] != 16) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of iv is wrong. Length of iv should be 16(128bits)"
                                     userInfo:nil];
    }
    if ([key length] != 16 && [key length] != 24 && [key length] != 32 ) {
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Length of key is wrong. Length of iv should be 16, 24 or 32(128, 192 or 256bits)"
                                     userInfo:nil];
    }
    
    // setup output buffer
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    // do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          [key bytes],     // Key
                                          [key length],    // kCCKeySizeAES
                                          [iv bytes],       // IV
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:buffer length:encryptedSize];
        free(buffer);
        
        return result;
    }
    else {
        free(buffer);
        @throw [NSException exceptionWithName:@"Cocoa Security"
                                       reason:@"Decrypt Error!"
                                     userInfo:nil];
        return nil;
    }
}


#pragma mark - MD5
+ (CocoaSecurityResult *)md5:(NSString *)hashString
{
    return [self md5WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)md5WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_MD5_DIGEST_LENGTH);
    
    CC_MD5([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark - HMAC-MD5
+ (CocoaSecurityResult *)hmacMd5:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacMd5WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (CocoaSecurityResult *)hmacMd5WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_MD5_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}


#pragma mark - SHA1
+ (CocoaSecurityResult *)sha1:(NSString *)hashString
{
    return [self sha1WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)sha1WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    
    CC_SHA1([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA224
+ (CocoaSecurityResult *)sha224:(NSString *)hashString
{
    return [self sha224WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)sha224WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA224_DIGEST_LENGTH);
    
    CC_SHA224([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA256
+ (CocoaSecurityResult *)sha256:(NSString *)hashString
{
    return [self sha256WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)sha256WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    
    CC_SHA256([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA384
+ (CocoaSecurityResult *)sha384:(NSString *)hashString
{
    return [self sha384WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)sha384WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    
    CC_SHA384([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    
    return result;
}
#pragma mark SHA512
+ (CocoaSecurityResult *)sha512:(NSString *)hashString
{
    return [self sha512WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)sha512WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_SHA512_DIGEST_LENGTH);
    
    CC_SHA512([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    free(digest);
    
    return result;
}


#pragma mark - HMAC-SHA1
+ (CocoaSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha1WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (CocoaSecurityResult *)hmacSha1WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA224
+ (CocoaSecurityResult *)hmacSha224:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha224WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (CocoaSecurityResult *)hmacSha224WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA224_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA224, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA224_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA256
+ (CocoaSecurityResult *)hmacSha256:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha256WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (CocoaSecurityResult *)hmacSha256WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA384
+ (CocoaSecurityResult *)hmacSha384:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha384WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (CocoaSecurityResult *)hmacSha384WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA384, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}
#pragma mark HMAC-SHA512
+ (CocoaSecurityResult *)hmacSha512:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha512WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (CocoaSecurityResult *)hmacSha512WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA512_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA512, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}

#pragma mark DES
const char basekey[] = { (Byte) 0xb9, (Byte)0x89, (Byte) 0x84, (Byte) 0xcf, (Byte) 0x9f, (Byte)0xd0, (Byte) 0xc5, 0x78, 0x19, (Byte) 0xe9,
    (Byte) 0x56, (Byte) 0x55,(Byte)0xbc, (Byte) 0x62, (Byte)0xda, (Byte)0x98, (Byte)0x82, (Byte)0e8, 0x4c, (Byte) 0xda,
    (Byte) 0x2f, (Byte)0xdf, (Byte)0xe6, 0x55};

static void generateStamp(char *outBuf,size_t length)
{
    srand([[NSDate date] timeIntervalSince1970]);
    for (int i=0; i<length; i++) {
        int scope = 'z'-'a'+1;
        int c = 'a'+rand()%scope;
        outBuf[i] = c;
    }
}

static void generateKey(const char *baseKey, size_t keyLength, const char *stamp, size_t stampLength, char *finalKey)
{
    int basePos = 0;
    int stampPos = 0;
    while (basePos<keyLength) {
        finalKey[basePos] = baseKey[basePos]&(stamp[stampPos]);
        basePos++;
        stampPos++;
        if (basePos>=keyLength) {
            break;
        }
        if (stampPos>=stampLength) {
            stampPos=0;
        }
        finalKey[basePos] = baseKey[basePos]|(stamp[stampPos]);
        basePos++;
        stampPos++;
        if (basePos>=keyLength) {
            break;
        }
        if (stampPos>=stampLength) {
            stampPos=0;
        }
        finalKey[basePos] = baseKey[basePos]^(stamp[stampPos]);
        basePos++;
        stampPos++;
        if (basePos>=keyLength) {
            break;
        }
        if (stampPos>=stampLength) {
            stampPos=0;
        }
    }
}

+ (NSString*)generateStamp {
    char stamp[21];
    size_t stampLength = 8+rand()%13;
    generateStamp(stamp,stampLength);
    stamp[stampLength]= 0;
    return [NSString stringWithUTF8String:stamp];
}

+ (NSData*)encyptPostData:(NSData *)data withStamp:(NSString*)stampString
{
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:128];
    
    //PKCS5 padding
    const char*rawbyters = [data bytes];
    size_t rawlength = [data length];
    size_t padlength = rawlength%8;
    padlength = 8-padlength;
    size_t lengthAfterPad = rawlength+padlength;
    void *paddedBytes = malloc(lengthAfterPad);
    memcpy(paddedBytes, rawbyters,rawlength);
    memset(paddedBytes+rawlength,(int)padlength,padlength);
    
    char *encyptBytes = malloc(lengthAfterPad);
    size_t numBytesEncrypted;
    
    const char * stamp = [stampString cStringUsingEncoding:NSUTF8StringEncoding];
    size_t stampLength = strlen(stamp);
    
    char key[24];
    generateKey(basekey,24,stamp,stampLength,key);
    
    CCCryptorStatus status = CCCrypt(kCCEncrypt,kCCAlgorithm3DES , kCCOptionECBMode, key, kCCKeySize3DES,NULL, paddedBytes, lengthAfterPad, encyptBytes, lengthAfterPad, &numBytesEncrypted);
    if (status==kCCSuccess) {
        size_t base64length = EstimateBas64EncodedDataSize(numBytesEncrypted);
        char *base64Buffer = malloc(base64length);
        Base64EncodeData(encyptBytes,numBytesEncrypted,base64Buffer,&base64length);
        [encryptedData appendBytes:base64Buffer length:base64length];
        free(base64Buffer);
    }
    free(paddedBytes);
    free(encyptBytes);
    return encryptedData;
}

+ (NSData *)decryptPostData:(NSData*)encryptData withStamp:(NSString*)stampString {
    
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:128];
    
    char key[24];
    NSData* stamp = [stampString dataUsingEncoding:NSUTF8StringEncoding];
    NSData* data = encryptData;
    generateKey(basekey,24,[stamp bytes],[stamp length],key);
    
    char * unBase64Buffer = malloc([data length]+1);
    size_t unBase64BufferLength = [data length]+1;
    Base64DecodeData([data bytes],[data length],unBase64Buffer,&unBase64BufferLength);
    unBase64Buffer[unBase64BufferLength] = 0;
    
    char * decryptBuffer = malloc([data length]+1);
    size_t decryptBufferLength = 0;
    
    CCCryptorStatus status = CCCrypt(kCCDecrypt,kCCAlgorithm3DES , kCCOptionECBMode, key, kCCKeySize3DES,NULL, unBase64Buffer, unBase64BufferLength, decryptBuffer, unBase64BufferLength, &decryptBufferLength);
    if (status==kCCSuccess) {
        int padlength = decryptBuffer[decryptBufferLength-1];
        [encryptedData appendBytes:decryptBuffer length:decryptBufferLength-padlength];
    }
    free(unBase64Buffer);
    free(decryptBuffer);
    return encryptedData;
}

#pragma mark XXTEA
static int DELTA = 0x9E3779B9;
#define MX (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z))


#define FIXED_KEY \
size_t i;\
uint8_t fixed_key[16];\
if (key.length < 16) {\
memcpy(fixed_key, key.bytes, key.length);\
for (i = key.length; i < 16; ++i) fixed_key[i] = 0;\
}\
else memcpy(fixed_key, key.bytes, 16);\

static uint32_t * xxtea_to_uint_array(const uint8_t * data, size_t len, int inc_len, size_t * out_len) {
    uint32_t *out;
    size_t n;
    
    n = (((len & 3) == 0) ? (len >> 2) : ((len >> 2) + 1));
    
    if (inc_len) {
        out = (uint32_t *)calloc(n + 1, sizeof(uint32_t));
        if (!out) return NULL;
        out[n] = (uint32_t)len;
        *out_len = n + 1;
    }
    else {
        out = (uint32_t *)calloc(n, sizeof(uint32_t));
        if (!out) return NULL;
        *out_len = n;
    }
#if defined(BYTE_ORDER) && (BYTE_ORDER == LITTLE_ENDIAN)
    memcpy(out, data, len);
#else
    for (size_t i = 0; i < len; ++i) {
        out[i >> 2] |= (uint32_t)data[i] << ((i & 3) << 3);
    }
#endif
    
    return out;
}

static uint8_t * xxtea_to_ubyte_array(const uint32_t * data, size_t len, int inc_len, size_t * out_len) {
    uint8_t *out;
    size_t m, n;
    
    n = len << 2;
    
    if (inc_len) {
        m = data[len - 1];
        n -= 4;
        if ((m < n - 3) || (m > n)) return NULL;
        n = m;
    }
    
    out = (uint8_t *)malloc(n + 1);
    
#if defined(BYTE_ORDER) && (BYTE_ORDER == LITTLE_ENDIAN)
    memcpy(out, data, n);
#else
    for (size_t i = 0; i < n; ++i) {
        out[i] = (uint8_t)(data[i >> 2] >> ((i & 3) << 3));
    }
#endif
    
    out[n] = '\0';
    *out_len = n;
    
    return out;
}

static uint32_t * xxtea_uint_encrypt(uint32_t * data, size_t len, uint32_t * key) {
    uint32_t n = (uint32_t)len - 1;
    uint32_t z = data[n], y, p, q = 6 + 52 / (n + 1), sum = 0, e;
    
    if (n < 1) return data;
    
    while (0 < q--) {
        sum += DELTA;
        e = sum >> 2 & 3;
        
        for (p = 0; p < n; p++) {
            y = data[p + 1];
            z = data[p] += MX;
        }
        
        y = data[0];
        z = data[n] += MX;
    }
    
    return data;
}

static uint32_t * xxtea_uint_decrypt(uint32_t * data, size_t len, uint32_t * key) {
    uint32_t n = (uint32_t)len - 1;
    uint32_t z, y = data[0], p, q = 6 + 52 / (n + 1), sum = q * DELTA, e;
    
    if (n < 1) return data;
    
    while (sum != 0) {
        e = sum >> 2 & 3;
        
        for (p = n; p > 0; p--) {
            z = data[p - 1];
            y = data[p] -= MX;
        }
        
        z = data[n];
        y = data[0] -= MX;
        sum -= DELTA;
    }
    
    return data;
}

static uint8_t * xxtea_ubyte_encrypt(const uint8_t * data, size_t len, const uint8_t * key, size_t * out_len) {
    uint8_t *out;
    uint32_t *data_array, *key_array;
    size_t data_len, key_len;
    
    if (!len) return NULL;
    
    data_array = xxtea_to_uint_array(data, len, 1, &data_len);
    if (!data_array) return NULL;
    
    key_array  = xxtea_to_uint_array(key, 16, 0, &key_len);
    if (!key_array) {
        free(data_array);
        return NULL;
    }
    
    out = xxtea_to_ubyte_array(xxtea_uint_encrypt(data_array, data_len, key_array), data_len, 0, out_len);
    
    free(data_array);
    free(key_array);
    
    return out;
}

static uint8_t * xxtea_ubyte_decrypt(const uint8_t * data, size_t len, const uint8_t * key, size_t * out_len) {
    uint8_t *out;
    uint32_t *data_array, *key_array;
    size_t data_len, key_len;
    
    if (!len) return NULL;
    
    data_array = xxtea_to_uint_array(data, len, 0, &data_len);
    if (!data_array) return NULL;
    
    key_array  = xxtea_to_uint_array(key, 16, 0, &key_len);
    if (!key_array) {
        free(data_array);
        return NULL;
    }
    
    out = xxtea_to_ubyte_array(xxtea_uint_decrypt(data_array, data_len, key_array), data_len, 1, out_len);
    
    free(data_array);
    free(key_array);
    
    return out;
}

/**
 * XXTEA加密
 */

+ (NSString *)encryptXXTEA:(NSString *)data withKey:(NSString *)key {
    NSData *result = [self encryptString:data andKey:key];
    NSString *resultStr = [result nip_Base64EncodedString];
    
    return resultStr;
}

+ (NSData *)encryptString:(NSString *)data andKey:(NSString *)key {
    NSData *dataByte = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyByte = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self encryptDataByte:dataByte andKeyByte:keyByte];
}

+ (NSData *)encryptDataByte:(NSData *)data andKeyByte:(NSData *)key {
    size_t out_len;
    FIXED_KEY
    void * bytes = xxtea_ubyte_encrypt(data.bytes, data.length, fixed_key, &out_len);
    return [NSData dataWithBytesNoCopy:bytes length:out_len freeWhenDone:YES];
}


/**
 * XXTEA解密
 */

+ (NSString *)decryptXXTEA:(NSString *)string withKey:(NSString *)key {
    NSData *result = [self decryptXXTEAData:string withKey:key];
    NSString *resultStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    return resultStr;
}

+ (NSData *)decryptXXTEAData:(NSString *)string withKey:(NSString *) key {
    NSData *dataByte = [string nip_Base64DecodedData];
    NSData *keyByte = [key dataUsingEncoding:NSUTF8StringEncoding];
    return [self decryptDataByte:dataByte andKeyByte:keyByte];
}

+ (NSData *)decryptDataByte:(NSData *)data andKeyByte:(NSData *)key {
    size_t out_len;
    FIXED_KEY
    void * bytes = xxtea_ubyte_decrypt(data.bytes, data.length, fixed_key, &out_len);
    if (bytes == NULL) return nil;
    return [NSData dataWithBytesNoCopy:bytes length:out_len freeWhenDone:YES];
}

@end

#pragma mark - CocoaSecurityResult
@implementation CocoaSecurityResult

@synthesize data = _data;

#pragma mark - Init
- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length
{
    self = [super init];
    if (self) {
        _data = [NSData dataWithBytes:initData length:length];
    }
    return self;
}

#pragma mark UTF8 String
// convert CocoaSecurityResult to UTF8 string
- (NSString *)utf8String
{
    NSString *result = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark HEX
// convert CocoaSecurityResult to HEX string
- (NSString *)hex
{
    CocoaSecurityEncoder *encoder = [CocoaSecurityEncoder new];
    return [encoder hex:_data useLower:false];
}
- (NSString *)hexLower
{
    CocoaSecurityEncoder *encoder = [CocoaSecurityEncoder new];
    return [encoder hex:_data useLower:true];
}

#pragma mark Base64
// convert CocoaSecurityResult to Base64 string
- (NSString *)base64
{
    CocoaSecurityEncoder *encoder = [CocoaSecurityEncoder new];
    return [encoder base64:_data];
}

@end


#pragma mark - CocoaSecurityEncoder
@implementation CocoaSecurityEncoder

// convert NSData to Base64
- (NSString *)base64:(NSData *)data
{
    return [data nip_Base64EncodedString];
}

// convert NSData to hex string
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower
{
    if (data.length == 0) { return nil; }
    
    static const char HexEncodeCharsLower[] = "0123456789abcdef";
    static const char HexEncodeChars[] = "0123456789ABCDEF";
    char *resultData;
    // malloc result data
    resultData = malloc([data length] * 2 +1);
    // convert imgData(NSData) to char[]
    unsigned char *sourceData = ((unsigned char *)[data bytes]);
    NSUInteger length = [data length];
    
    if (isOutputLower) {
        for (NSUInteger index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeCharsLower[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeCharsLower[(sourceData[index] % 0x10)];
        }
    }
    else {
        for (NSUInteger index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeChars[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeChars[(sourceData[index] % 0x10)];
        }
    }
    resultData[[data length] * 2] = 0;
    
    // convert result(char[]) to NSString
    NSString *result = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    sourceData = nil;
    free(resultData);
    
    return result;
}

@end

#pragma mark - CocoaSecurityDecoder
@implementation CocoaSecurityDecoder
- (NSData *)base64:(NSString *)string
{
    return [NSData nip_DataWithBase64EncodedString:string];
}
- (NSData *)hex:(NSString *)data
{
    if (data.length == 0) { return nil; }
    
    static const unsigned char HexDecodeChars[] =
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //49
        2, 3, 4, 5, 6, 7, 8, 9, 0, 0, //59
        0, 0, 0, 0, 0, 10, 11, 12, 13, 14,
        15, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 10, 11, 12,   //99
        13, 14, 15
    };
    
    // convert data(NSString) to CString
    const char *source = [data cStringUsingEncoding:NSUTF8StringEncoding];
    // malloc buffer
    unsigned char *buffer;
    NSUInteger length = strlen(source) / 2;
    buffer = malloc(length);
    for (NSUInteger index = 0; index < length; index++) {
        buffer[index] = (HexDecodeChars[source[index * 2]] << 4) + (HexDecodeChars[source[index * 2 + 1]]);
    }
    // init result NSData
    NSData *result = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    source = nil;
    
    return  result;
}

@end
