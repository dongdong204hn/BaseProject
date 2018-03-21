//
//  NIPDeviceLocalAuthorization.h
//  rnCodes
//
//  Created by bjjiachunhui on 2017/4/19.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger,NIPFingerRecognizerMode)
{
    
    NIPFingerRecognizerModeWithBiometricsLocakedOutdUsePasscode=0,
    NIPFingerRecognizerModeWithBiometricsAndPasscode=1,
    NIPFingerRecognizerModeWithBiometricsOnly=2,
    
};
/*
 0     Success,                        // 指纹验证成功
 -1     LAErrorAuthenticationFailed,    // 验证信息出错，就是说你指纹不对
 -2     LAErrorUserCancel               // 用户取消了验证
 -3     LAErrorUserFallback             // 用户点击了手动输入密码的按钮，所以被取消了
 -4     LAErrorSystemCancel             // 被系统取消，就是说你现在进入别的应用了，不在刚刚那个页面，所以没法验证
 -5     LAErrorPasscodeNotSet           // 用户没有设置TouchID
 -6     LAErrorTouchIDNotAvailable      // 用户设备不支持TouchID
 -7     LAErrorTouchIDNotEnrolled       // 用户没有设置手指指纹
 -8     LAErrorTouchIDLockout           // 用户错误次数太多，现在被锁住了
 -9     LAErrorAppCancel                // 在验证中被其他app中断
 -10    LAErrorInvalidContext           // 请求验证出错
 */

typedef void (^NIPLAReplyBlock)(NSArray * _Nonnull response);


@interface NIPFingerRecognizerManager : NSObject


+ (void)fingerRecognizerWithMode:(NIPFingerRecognizerMode)mode reason:(NSString * _Nonnull)reason localizedCancelTitle:(NSString *_Nullable)cancelTitle localizedFallbackTitle:(NSString *_Nullable)fallbackTitle reply:(NIPLAReplyBlock _Nonnull )reply;

+ (bool)canDeviceSupportFingerRecgonizer;

+ (NSString *)BiometryTypeDeviceSupport;

@end
