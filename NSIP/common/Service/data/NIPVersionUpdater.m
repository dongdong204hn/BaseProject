//
//  NIPVersionUpdater.m
//  NSIP
//
//  Created by 赵松 on 16/12/8.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPVersionUpdater.h"
#import "nip_network.h"
#import "nip_macros.h"
#import "nip_ui_alert.h"
#import "NSDictionary+NIPBasicAdditions.h"
#import "NSString+NIPBasicAdditions.h"

@interface NIPVersionUpdater ()

@property (nonatomic, strong) NIPBaseRequest *request;
@property (nonatomic, strong) NSString *urlString;;

@end

@implementation NIPVersionUpdater

@synthesize maxVersion,minVersion;
@synthesize inVersion,itunesUrl,desc;
@synthesize serverTime;
@synthesize silently=_silently;
@synthesize actionCompletionBlock=_completionBlock;

+ (void)checkVersion:(BOOL)silently withUrlString:(NSString*)urlString withCompletion:(SimpleCompletionBlock)block {
    NIPVersionUpdater *action = [[NIPVersionUpdater alloc] init];
    action.silently = silently;
    action.urlString = urlString;
    action.actionCompletionBlock = block;
    action.singleAction = silently;
    [action execute];
}

-(id)init{
    if (self = [super init]) {
    }
    return self;
}

- (void)main {
    WEAK_SELF(weakSelf)
    _request = [[NIPHTTPSessionManager sharedManager] requestWithPath:self.urlString
                                                               method:NIPHttpRequestMethodGet
                                                           parameters:@{@"mobile_os_type":@"iPhone"}
                                            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                            }
                                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                  [weakSelf processLatestVersionInfo:responseObject];
                                                                  [weakSelf setComplete];
                                                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                  [weakSelf processError:error];
                                                                  [weakSelf setComplete];
                                                              }];
}

- (void)processError:(NSError*)error {
    if (!self.silently) {
        [NIPAlertView alertWithTitle:nil andMessage:[error localizedDescription]];
    }
    if (self.actionCompletionBlock) {
        self.actionCompletionBlock();
    }
}

- (void)processLatestVersionInfo:(NSDictionary*)versionInfo {
    if ([versionInfo objectForKey:@"object"]) {
        versionInfo = [versionInfo objectForKey:@"object"];
        self.maxVersion = [versionInfo stringForKey:@"version"];
        self.minVersion = [versionInfo stringForKey:@"minorVer"];
        self.itunesUrl = [versionInfo stringForKey:@"wapUrl"];
        self.desc = [[versionInfo stringForKey:@"desc"] stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
        WEAK_SELF(weakSelf)
        if (NSOrderedDescending == [self.minVersion compareNumerically:APP_VERSION withSepateString:@"."]) {
            NIPAlertView *alertView = [[NIPAlertView alloc] initWithTitle:@"您的版本过低,需要更新才能进行下一步操作"
                                                                  message:weakSelf.desc
                                                        cancelButtonTitle:@"现在更新"
                                                        otherButtonTitles:nil, nil];
            alertView.onDismissBlock = ^(NSInteger buttonIndex) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesUrl]];
            };
            [alertView show];
        } else if (NSOrderedDescending == [self.maxVersion compareNumerically:APP_VERSION withSepateString:@"."]) {
            NIPAlertView *alertView = [[NIPAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版%@ 可以更新了",self.maxVersion]
                                                                  message:weakSelf.desc
                                                        cancelButtonTitle:@"暂不更新"
                                                        otherButtonTitles:@"现在更新", nil];
            alertView.onDismissBlock = ^(NSInteger buttonIndex) {
                if (buttonIndex==1)
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesUrl]];
            };
            [alertView show];
        } else {
            if (!self.silently) {
                [NIPAlertView alertWithTitle:@"目前已是最新版本了" andMessage:nil];
            }
        }
    }
    if (self.actionCompletionBlock) {
        self.actionCompletionBlock();
    }
}

@end