//
//  NIPinyinFormatter.h
//  NSIP
//
//  Created by 赵松 on 16/12/15.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIPHanyuPinyinOutputFormat;

@interface NIPinyinFormatter : NSObject {
}

+ (NSString *)formatHanyuPinyinWithNSString:(NSString *)pinyinStr
                withHanyuPinyinOutputFormat:(NIPHanyuPinyinOutputFormat *)outputFormat;
+ (NSString *)convertToneNumber2ToneMarkWithNSString:(NSString *)pinyinStr;
- (id)init;
@end

