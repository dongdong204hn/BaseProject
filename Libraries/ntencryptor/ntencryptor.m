//
//  ntencryptor.m
//  ntencryptor
//
//  Created by  龙会湖 on 14-4-14.
//  Copyright (c) 2014年 netease. All rights reserved.
//
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import "ntencryptor.h"
#import "ntencryptor_data.h"

static unsigned char _aesKey[kCCKeySizeAES128];
static BOOL _aesKeyIntilized;

// 1. 加密包拿到key后，kmd5 = md5(key)
// 2. key2 =  “movie163” + kmd5+ 一大段英文 ;  (movie163和一大段英文是由c语言函数生成的)
// 3. key3 = md5(key2)，后台可以对每个平台，版本缓存一下key3
// 4. aeskey = kmd5+key3
// 5. return AES(data,aeskey)
void ntencryptor_setkey(NSString* key) {
    if (key.length==0) {
        return;
    }
    
    unsigned char *(*func1)() ;
    unsigned char *(*func2)() ;

    //下面这行注释+代码块不要修改，脚本文件会自动替换
    //rand_function_replace
    {
    func1 = vmreOaWUNP;
    func2 = zezoZXAhRT;
    }
    
    const char* key_chars = [key UTF8String];
    unsigned char key_md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5(key_chars, (CC_LONG)strlen(key_chars), key_md5);
    
    unsigned const char *rand_str1 = func1();
    unsigned const char *rand_str2 = func2();
    size_t rand_str1_length =  strlen((const char*)rand_str1);
    size_t rand_str2_length =  strlen((const char*)rand_str2);
    size_t key2_length = rand_str1_length+rand_str2_length+CC_MD5_DIGEST_LENGTH;
    unsigned char *key2_buffer = malloc(key2_length);
    memcpy(key2_buffer, rand_str1, rand_str1_length);
    memcpy(key2_buffer+rand_str1_length, key_md5,CC_MD5_DIGEST_LENGTH);
    memcpy(key2_buffer+rand_str1_length+CC_MD5_DIGEST_LENGTH, rand_str2, rand_str2_length);

    
    unsigned char key3_buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(key2_buffer, (CC_LONG)key2_length, key3_buffer);
    
    memcpy(_aesKey, key3_buffer, CC_MD5_DIGEST_LENGTH);
    
    free(key2_buffer);
    _aesKeyIntilized = YES;
    
#if DEBUG
    NSMutableString *mutableString = [[NSMutableString alloc] initWithString:@"ntencryptor aes_key is: "];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [mutableString appendFormat:@"%02x,",_aesKey[i]];
    }
    NSLog(@"%@",mutableString);
#endif
}

NSData* ntencryptor_encrypt_data(NSData* data) {
    if (!_aesKeyIntilized) {
        @throw [NSException exceptionWithName:@"NTEncryptor"
                                       reason:@"encryt key not initialized" userInfo:nil];
    }
    
	NSUInteger dataLength = [data length];
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionECBMode + kCCOptionPKCS7Padding,_aesKey, kCCKeySizeAES128,
										  NULL /* initialization vector (optional) */,
										  [data bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
    
    NSData * encryptedData = nil;
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		encryptedData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	} else {
        free(buffer);
    }
	return encryptedData;
}

NSData *ntencryptor_decrypt_data(NSData* data) {
    if (!_aesKeyIntilized) {
        @throw [NSException exceptionWithName:@"NTEncryptor"
                                       reason:@"encryt key not initialized" userInfo:nil];
    }
	NSUInteger dataLength = [data length];
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionECBMode + kCCOptionPKCS7Padding,
										  _aesKey, kCCKeySizeAES128,
										  NULL /* initialization vector (optional) */,
										  [data bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
    NSData * decryptedData = nil;
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
        decryptedData =  [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	} else {
        free(buffer);
    }
	return decryptedData;
}
