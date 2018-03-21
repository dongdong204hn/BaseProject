//
//  NIPKeyboardManager.m
//  NSIP
//
//  Created by bjjiachunhui on 2017/4/26.
//  Copyright © 2017年 netease. All rights reserved.
//

#import "NIPKeyboardManager.h"
#import "NIPLocalSettings.h"


static NSString * const IS_ALLOW_THIRD_KEYBOARD_KEY = @"IS_ALLOW_THIRD_KEYBOARD_KEY";


@implementation NIPKeyboardManager


/**
 获取本机是否装了第三方键盘
 
 @return 返回获取状态BOOL类型
 */
+ (BOOL)hasThirdKeyboard
{
    BOOL hasThirdKeyboard = NO;
    NSArray *activeInputModes = [UITextInputMode activeInputModes];
    for (UITextInputMode * inputMode in activeInputModes) {
        if ([NSStringFromClass([inputMode class]) isEqualToString:@"UIKeyboardExtensionInputMode"]) {
            hasThirdKeyboard = YES;
            break;
        }
    }
    return hasThirdKeyboard;
}

/**
 设置对第三方键盘的支持性
 特别说明
 app只能键盘第一次出现之前设定不支持，一旦中间有过支持第三方键盘就一直支持第三方键盘，必须在appDelegate里面用
 
 @param availability BOOL类型，表示可用性
 @return
 */
+ (void)setThirdKeyboardAvailability:(BOOL)availability
{
    NIPLocalSettings * localSetting=[NIPLocalSettings settings];
    [localSetting setSettingValue:@(availability) forKey:IS_ALLOW_THIRD_KEYBOARD_KEY];
}

/**
 获取第三方键盘的可用性
 
 @return 返回可用性结果BOOL类型，默认支持
 */
+ (BOOL)getThirdKeyboardAvailability
{
    NIPLocalSettings * localSetting=[NIPLocalSettings settings];
    NSNumber *isAllowThirdKeyboard = [localSetting settingValueForKey:IS_ALLOW_THIRD_KEYBOARD_KEY];
    
    if (isAllowThirdKeyboard) {
        return isAllowThirdKeyboard.boolValue;
    } else {
        return true;
    }
}

@end
