//
//  NSString+URS.h
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URS)
- (NSString *)urs_URLEncodedString;
- (NSString *)urs_URLDecodedString;
- (NSString *)urs_md5;
- (NSData * )urs_base16Data;
- (NSInteger)urs_letterCount;
- (NSInteger)urs_numCount;
@end
