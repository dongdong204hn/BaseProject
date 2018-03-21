//
//  NIPSoundManager.h
//  NSIP
//
//  Created by 赵松 on 16/12/14.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  播放系统提示音，注册系统提示音，设备振动。播放系统提示音前需要先注册
 */
@interface NIPSoundManager : NSObject

+ (instancetype)sharedInstance;

//! 振动
+ (void)vibrate;
#pragma mark -
- (void)registerSoundWithFileName:(NSString *)fileName;

- (void)playSoundWithFileName:(NSString *)soundFileName;

@end
