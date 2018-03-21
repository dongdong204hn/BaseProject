//
//  NIPHanyuPinyinOutputFormat.m
//  NSIP
//
//  Created by 赵松 on 16/12/15.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPHanyuPinyinOutputFormat.h"

@implementation NIPHanyuPinyinOutputFormat
@synthesize vCharType = _vCharType;
@synthesize caseType = _caseType;
@synthesize toneType = _toneType;
@synthesize bracketType = _bracketType;

- (id)init {
  if (self = [super init]) {
    [self restoreDefault];
  }
  return self;
}

- (void)restoreDefault {
    _vCharType = VCharTypeWithUUnicode;
    _caseType = CaseTypeLowercase;
    _toneType = ToneTypeWithToneMark;
    _bracketType = BracketTypeExist;
}

@end
