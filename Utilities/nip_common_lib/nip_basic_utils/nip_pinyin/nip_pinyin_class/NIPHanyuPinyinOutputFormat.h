//
//  NIPHanyuPinyinOutputFormat.h
//  NSIP
//
//  Created by 赵松 on 16/12/15.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

//! 声调类型
typedef enum {
  ToneTypeWithToneNumber, //数字来标识
  ToneTypeWithoutTone, //不显示声调
  ToneTypeWithToneMark //直接在字母上方标识声调
}ToneType;

//! 大小写
typedef enum {
    CaseTypeUppercase, //全大写
    CaseTypeLowercase  //全小写
}CaseType;

//! v的显示类型
typedef enum {
    VCharTypeWithUAndColon, //u:
    VCharTypeWithV, //v
    VCharTypeWithUUnicode //ü
}VCharType;

typedef enum {
    BracketTypeExist,
    BracketTypeNone
}BracketType;

@interface NIPHanyuPinyinOutputFormat : NSObject

@property(nonatomic, assign) VCharType vCharType;
@property(nonatomic, assign) CaseType caseType;
@property(nonatomic, assign) ToneType toneType;
@property(nonatomic, assign) BracketType bracketType;

- (id)init;
- (void)restoreDefault;
@end

