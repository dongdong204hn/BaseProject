//
//  ntencryptor.h
//  ntencryptor
//
//  Created by  龙会湖 on 14-4-14.
//  Copyright (c) 2014年 netease. All rights reserved.
//

void ntencryptor_setkey(NSString* key);
NSData* ntencryptor_encrypt_data(NSData* data);
NSData *ntencryptor_decrypt_data(NSData* data);
