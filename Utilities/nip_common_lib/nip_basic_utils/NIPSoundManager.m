//
//  NIPSoundManager.m
//  NSIP
//
//  Created by 赵松 on 16/12/14.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSoundManager.h"
#import <AudioToolbox/AudioServices.h>
#import "nip_macros.h"
#import "NSDictionary+NIPBasicAdditions.h"

@interface NIPSoundManager()
{
    NSMutableDictionary * _soundType2Id;
}
@end

@implementation NIPSoundManager

+ (instancetype)sharedInstance
{
    static id sInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInst = [[self alloc] init];
    });
    return sInst;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerSounds];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterSounds];
}

- (void)playSoundWithFileName:(NSString *)soundFileName
{
    if (notEmptyString(soundFileName)) {
        NSNumber * soundId = [_soundType2Id validObjectForKey:soundFileName];
        if (soundId) {
            AudioServicesPlaySystemSound([soundId unsignedIntValue]);
        }
    }
}

#pragma mark - 系统提示音注册

- (void)registerSounds
{
    if (!_soundType2Id) {
        _soundType2Id = [NSMutableDictionary new];
    }
    // 注册默认的提示音。业务不同所注册的不同，eg:sent.caf
    [self registerSoundWithFileName:@"sent.caf"];
}

- (void)unregisterSounds
{
    for (NSString *fileName in _soundType2Id.allKeys) {
        [self unregisterSoundWithFileName:fileName];
    }
    
    [_soundType2Id removeAllObjects];
}

- (void)registerSoundWithFileName:(NSString *)fileName
{
    if (!notEmptyString(fileName)) {
        return;
    }
    NSArray *components = [fileName componentsSeparatedByString:@"."];
    if (2 == components.count) {
        NSString * path  = [[NSBundle mainBundle] pathForResource:components[0] ofType:components[1]];
        NSURL * pathURL = [NSURL fileURLWithPath:path];
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &audioEffect);
        
        _soundType2Id[fileName] = [NSNumber numberWithUnsignedLong:audioEffect];
    }
}

- (void)unregisterSoundWithFileName:(NSString *)fileName
{
    NSNumber * soundId = _soundType2Id[fileName];
    AudioServicesDisposeSystemSoundID([soundId unsignedIntValue]);
}

#pragma mark - 设备振动
+ (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end