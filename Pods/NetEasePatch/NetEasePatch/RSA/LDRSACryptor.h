//
//  LDRSACryptor.h
//  NetEasePatch
//
//  Created by ss on 15/9/22.
//  Copyright (c) 2015年 Hui Pang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface LDRSACryptor : NSObject {
    SecKeyRef _publicKey;
}

+ (instancetype)defaultCryptor;

/**
 @abstract  import public key, call before 'encryptWithPublicKey'
 @param     publicKey with base64 encoded
 @return    Success or not.
 */
- (BOOL)importRSAPublicKeyBase64:(NSString *)publicKey;

/**
 @abstract  export public key, 'importRSAPublicKeyBase64' should call before this method
 @return    public key base64 encoded
 */
- (NSString *)base64EncodedPublicKey;

/**
 @abstract  decrypt text using RSA public key
 @param     padding type add the plain text
 @return    encrypted data
 */
- (NSData *)decryptWithPublicKeyUsingData:(NSData *)data;

@end
