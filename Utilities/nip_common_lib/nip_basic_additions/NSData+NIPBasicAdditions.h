//
//  NSData+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  NSData NTBasicAdditions
 */
@interface NSData (NIPBasicAddtions)

/**
 * Calculate the md5 hash of the data using CC_MD5.
 *
 * @return md5 hash of the data
 */
@property (nonatomic, readonly) NSString *md5Hash;

- (NSData *)base64Encoding;
- (NSData *)base64Decoding;
- (NSString *)base16String;
- (NSData *)aes256EncryptWithKey:(NSString *)key;
- (NSData *)aes256DecryptWithKey:(NSString *)key;
- (NSData *)md5Digest;

+ (NSData *)nip_DataWithBase64EncodedString:(NSString *)string;
- (NSString *)nip_Base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)nip_Base64EncodedString;

@end
