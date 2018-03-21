//
//  NIPFingerRecognizerModule.m
//  rnCodes
//
//  Created by bjjiachunhui on 2017/4/19.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "NIPFingerRecognizerManager.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "UIDevice+NIPBasicAdditions.h"
#import <UIKit/UIKit.h>

@implementation NIPFingerRecognizerManager

+ (void)fingerRecognizerWithMode:(NIPFingerRecognizerMode)mode reason:(NSString * _Nonnull)reason localizedCancelTitle:(NSString *_Nullable)cancelTitle localizedFallbackTitle:(NSString *_Nullable)fallbackTitle reply:(NIPLAReplyBlock _Nonnull )reply
{
    
    switch (mode) {
        case NIPFingerRecognizerModeWithBiometricsOnly:
        {
            [NIPFingerRecognizerManager  fingerRecognizerCanEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:reason localizedCancelTitle:cancelTitle localizedFallbackTitle:fallbackTitle  reply:reply failedUsePasscode:NO];
            break;
        }
        case NIPFingerRecognizerModeWithBiometricsAndPasscode:
        {
            [NIPFingerRecognizerManager fingerRecognizerCanEvaluatePolicy:LAPolicyDeviceOwnerAuthentication evaluatePolicy:LAPolicyDeviceOwnerAuthentication reason:reason localizedCancelTitle:cancelTitle localizedFallbackTitle:fallbackTitle  reply:reply failedUsePasscode:NO];
            break;
        }
        case NIPFingerRecognizerModeWithBiometricsLocakedOutdUsePasscode:
        {
            [NIPFingerRecognizerManager fingerRecognizerCanEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics reason:reason localizedCancelTitle:cancelTitle localizedFallbackTitle:fallbackTitle reply:reply failedUsePasscode:YES];
            break;
        }
    }
    
}



//支持不支持 0（成功）其他负数表示失败 最后面是描述信息
#pragma mark -- designed method
+ (void)fingerRecognizerCanEvaluatePolicy:(LAPolicy)canEvaluatePolicy  evaluatePolicy:(LAPolicy)evalutePolicy reason:(NSString *)reason localizedCancelTitle:(NSString *)cancelTitle localizedFallbackTitle:(NSString *_Nullable)fallbackTitle reply:(NIPLAReplyBlock _Nonnull )reply failedUsePasscode:(BOOL)failedUsePasscode
{
    float v=[[[UIDevice currentDevice] systemVersion] floatValue];
    //是否需要输入密码，字符串为空表示不需要
    LAContext * context=[LAContext new];
    if(fallbackTitle==nil)
        context.localizedFallbackTitle = @"";
    else context.localizedFallbackTitle=fallbackTitle;
    //是否自定义取消标题
    if(cancelTitle!=nil)
    {
        if(v<10.0)
        {
            //使用默认值
        }else
        {
            context.localizedCancelTitle=cancelTitle;
        }
     
    }
    
    NSError * error;
    if ([context canEvaluatePolicy:canEvaluatePolicy
                             error:&error]) {
        [context evaluatePolicy:evalutePolicy
                localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        reply(@[[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],@"vertify success"]);
                    }else{
                        reply(@[[NSNumber numberWithInt:1],[NSNumber numberWithInteger:error.code],error.description]);
                    }
                }];
    }else
    {
        if(v>=9.0 && failedUsePasscode && error.code==LAErrorTouchIDLockout)
        {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                    localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                        if (success)
                        {
                            [NIPFingerRecognizerManager fingerRecognizerCanEvaluatePolicy:canEvaluatePolicy evaluatePolicy:evalutePolicy reason:reason localizedCancelTitle:cancelTitle  localizedFallbackTitle:fallbackTitle reply:reply failedUsePasscode:YES];
                        }
                        else{
                            reply(@[[NSNumber numberWithInt:1],[NSNumber numberWithInteger:error.code],error.description]);
                        }
                    }];
            
        }else
        {
            reply(@[[NSNumber numberWithInt:0],[NSNumber numberWithInteger:error.code],error.description]);
        }
    }
}


//检测设备是否支持指纹识别
+ (bool)canDeviceSupportFingerRecgonizer
{
    NSError * error;
    LAContext * context=[LAContext new];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                             error:&error]) {
        return YES;
    }
    return NO;
}


+ (NSString *)BiometryTypeDeviceSupport
{
    NSString * deviceName = [UIDevice getDeviceName];
    
    if([deviceName isEqualToString:@"iPhone X"])
        return @"face id";
    return @"touch id";
}
@end



