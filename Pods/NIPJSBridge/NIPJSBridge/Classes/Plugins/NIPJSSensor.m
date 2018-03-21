//
//  NIPJSSensor.m
//  NIPJSBridge
//
//  Created by Eric on 2017/6/19.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSSensor.h"
#import <AVFoundation/AVFoundation.h>
#import "NIPJSInvokedURLCommand.h"
#import <UIKit/UIKit.h>


#define WEAK_SELF(weakSelf) __weak __typeof(self) weakSelf = self;

@interface NIPJSSensor ()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) double lowPassResults;

@property (nonatomic, assign) NSInteger recordTimeoutInterval;
@property (nonatomic, assign) NSInteger demandDB;
@property (nonatomic, assign) NSInteger demandTimes;
@property (nonatomic, copy) void (^recordCB)(NSDictionary *data) ;
@property (nonatomic, assign) NSInteger reachStandardTimes;
@property (nonatomic, strong) NSDate *recordStartDate;

@property (nonatomic, assign) BOOL recordMotionEnabled;
@property (nonatomic, assign) NSInteger demandShakeTimes;
@property (nonatomic, assign) NSInteger shakeTimes;
@property (nonatomic, copy) void (^recordMotionCB)(NSDictionary *data) ;

@end

@implementation NIPJSSensor


- (void)dealloc {
    [self stopMicRecord];
}


- (void)listenToMic:(NIPJSInvokedURLCommand *)command {
    NSString *timeoutIntervalStr = [command JSONParamForkey:@"timeout" withDefault:@""];
    NSInteger timeoutInterval = [timeoutIntervalStr integerValue];
    NSString *demandDBStr = [command JSONParamForkey:@"db" withDefault:@""];
    CGFloat demandDB = [demandDBStr doubleValue];
    NSString *demandTimesStr = [command JSONParamForkey:@"count" withDefault:@""];
    NSInteger demandTimes = [demandTimesStr integerValue];
    
    [self recordMicWithTimeoutInterval:timeoutInterval
                              demandDB:demandDB
                                 demandTimes:demandTimes
                              callback:^(NSDictionary *data) {
        NIPJSPluginResult *result = [NIPJSPluginResult resultWithStatus:NIPJSCommandStatus_OK
                                                    messageAsDictionary:data];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}


- (void)listenToMotion:(NIPJSInvokedURLCommand *)command {
    NSString *timeoutStr = [command JSONParamForkey:@"timeout" withDefault:@""];
    NSInteger timeout = [timeoutStr integerValue];
    NSString *countStr = [command JSONParamForkey:@"count" withDefault:@""];
    NSInteger count = [countStr integerValue];
    
    [self recordMotionWithTimeoutInterval:timeout
                              demandTimes:count
                                 callback:^(NSDictionary *data) {
                                     NIPJSPluginResult *result = [NIPJSPluginResult resultWithStatus:NIPJSCommandStatus_OK
                                                                                 messageAsDictionary:data];
                                     [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                                 }];
}

- (void)recordMicWithTimeoutInterval:(NSInteger)timeoutInterval
                            demandDB:(NSInteger)demandDB
                         demandTimes:(NSInteger)demandTimes
                            callback:(void(^)(NSDictionary *data))callback {
    self.recordTimeoutInterval = timeoutInterval;
    self.demandDB = demandDB;
    self.demandTimes = demandTimes;
    self.recordCB = callback;
    
    __block NSError *error = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                           error:&error];
    if (error) {
        self.recordCB(@{@"code":@3});
        return;
    }
    
    WEAK_SELF(weakSelf)
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if(granted) {
            NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
            
            NSDictionary *settings = @{
                                       AVSampleRateKey: @44100,
                                       AVFormatIDKey :  @(kAudioFormatAppleLossless),
                                       AVNumberOfChannelsKey : @2,
                                       AVEncoderAudioQualityKey : @(AVAudioQualityLow),
                                       AVEncoderBitRateKey : @16
                                       };
            
            weakSelf.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
            
            if (weakSelf.recorder) {
                [weakSelf.recorder prepareToRecord];
                weakSelf.recorder.meteringEnabled = YES;
                weakSelf.reachStandardTimes = 0;
                weakSelf.recordStartDate = [NSDate date];
                [weakSelf.recorder record];
            }
            
        } else {
            weakSelf.recordCB(@{@"count":@-1});
            NSString *alertMsg = @"请在iPhone的“设置-隐私-麦克风”选项中，允许立马理财访问你的麦克风";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:alertMsg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"我知道了"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * action) {
                                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  }];
            [alert addAction:defaultAction];
            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)startRecordTimer {
    [self startRecordTimer];
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                  target:self
                                                selector:@selector(recordTimerFired:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)recordTimerFired:(NSTimer *)timer {
    [self.recorder updateMeters];
    float level;                // The linear 0.0 .. 1.0 value we need.
    float minDecibels = - 80.0f; // Or use -60dB, which I measured in a silent room
    float decibels = [_recorder averagePowerForChannel:0];
    if (decibels < minDecibels)   {
        level = 0.0f;
    } else if (decibels >= 0.0f) {
        level = 1.0f;
    } else {
        float root            = 2.0f;
        float minAmp          = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp             = powf(10.0f, 0.05f * decibels);
        float adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    float sampleDB = level * 120;
    if (self.recordTimeoutInterval == 0 ||
        [[NSDate date] timeIntervalSinceDate:self.recordStartDate] < self.recordTimeoutInterval) {
        if (sampleDB > self.demandDB) {
            self.reachStandardTimes ++;
            
            if (self.reachStandardTimes >= self.demandTimes) {
                self.recordCB(@{@"count":@(self.reachStandardTimes)});
                self.reachStandardTimes = 0;
            }
        } else {
            self.reachStandardTimes = 0;
        }
    } else { //超时
        self.recordCB(@{@"count":@0});
        [self stopMicRecord];
    }
}

- (void)stopMicRecord{
    [self.timer invalidate];
    [self.recorder stop];
    self.timer = nil;
    self.recorder = nil;
}



- (void)recordMotionWithTimeoutInterval:(NSInteger)timeoutInterval
                            demandTimes:(NSInteger)count
                               callback:(void(^)(NSDictionary *))callback{
    self.demandShakeTimes = count;
    self.recordMotionCB = callback;
    self.recordMotionEnabled = YES;
    if (timeoutInterval > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.recordMotionEnabled = NO;
            if (self.recordMotionCB) {
                self.recordMotionCB(@{@"count":@0});
            }
        });
    }
    
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self.viewController becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake && self.recordMotionEnabled) {
        self.shakeTimes ++;
        if (self.shakeTimes >= self.demandShakeTimes) {
            self.recordMotionCB(@{@"count":@(self.shakeTimes)});
            self.recordMotionCB = nil;
            self.shakeTimes = 0;
        }
    }
    return;
}



@end
