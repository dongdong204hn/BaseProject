//
//  NIPJSShare.m
//  NIPJSBridge
//
//  Created by Eric on 2017/6/19.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSShare.h"
#import "NIPJSInvokedURLCommand.h"

@interface NIPJSShare ()

@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) NSString *callbackId;

@end

@implementation NIPJSShare


/*
 *@func  唤起分享面板
 */
- (void)showShareMenu:(NIPJSInvokedURLCommand *)command{
    self.callbackId = command.callbackId;
    self.shareInfo = @{@"imageurl":[command JSONParamForkey:@"imageurl"],
                       @"title" : [command JSONParamForkey:@"title"],
                       @"content":[command JSONParamForkey:@"content"],
                       @"stateSMS":[command JSONParamForkey:@"statesms"],
                       @"stateWX":[command JSONParamForkey:@"statewx"],
                       @"stateWXT":[command JSONParamForkey:@"statewxt"],
                       @"stateWB":[command JSONParamForkey:@"statewb"],
                       @"stateYX":[command JSONParamForkey:@"stateyx"],
                       @"stateYXT":[command JSONParamForkey:@"stateyxt"],
                       @"wxJumpUrl":[command JSONParamForkey:@"wxjumpurl"],
                       @"yxJumpUrl":[command JSONParamForkey:@"yxjumpurl"],
                       @"wbJumpUrl":[command JSONParamForkey:@"wbjumpurl"]};
//    [self showShareWithTag:0];
}



/*

- (void)showShareWithTag:(NSInteger)tag{
    UIImage *shareImage = nil;
    if (![_shareInfo[@"imageurl"] isEqualToString:@""]) {
        NSURL *shareImageUrl = [NSURL URLWithString:_shareInfo[@"imageurl"]];
        shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:shareImageUrl]];
    }
    
    NSString *title = _shareInfo[@"title"];
    NSString *content = _shareInfo[@"content"];
    //        NSString *stateSMS = [_shareInfo[@"stateSMS"] isEqualToString:@""]?content:_shareInfo[@"stateSMS"];
    //        NSString *stateWX = [_shareInfo[@"stateWX"] isEqualToString:@""]?content:_shareInfo[@"stateWX"];
    //        NSString *stateWXT = [_shareInfo[@"stateWXT"] isEqualToString:@""]?content:_shareInfo[@"stateWXT"];
    NSString *stateWB = [_shareInfo[@"stateWB"] isEqualToString:@""]?content:_shareInfo[@"stateWB"];
    //        NSString *stateYX = [_shareInfo[@"stateYX"] isEqualToString:@""]?content:_shareInfo[@"stateYX"];
    //        NSString *stateYXT = [_shareInfo[@"stateYXT"] isEqualToString:@""]?content:_shareInfo[@"stateYXT"];
    NSString *wxJumpUrl = _shareInfo[@"wxJumpUrl"];
    //        NSString *yxJumpUrl = _shareInfo[@"yxJumpUrl"];
    //        NSString *wbJumpUrl = _shareInfo[@"wbJumpUrl"] ;
    if (tag) {
        CFShareAlertView *shareView = [[CFShareAlertView new] show];
        [shareView postTitle:title message:content image:shareImage redirectToLinkContent:wxJumpUrl];
        [shareView postMessage:stateWB.length > 0? stateWB:content image:shareImage];
        //以下代码如果不需要处理分享成功或者取消的情况可以不写，只写上面的即可
        shareView.delegate = (id<NTShareKitDelegate>)self;
    }else{
        NTShareAlertView *shareView = [[NTShareAlertView new] show];
        [shareView postTitle:title message:content image:shareImage redirectToLinkContent:wxJumpUrl];
        [shareView postMessage:stateWB.length > 0? stateWB:content image:shareImage];
        //以下代码如果不需要处理分享成功或者取消的情况可以不写，只写上面的即可
        shareView.delegate = (id<NTShareKitDelegate>)self;
    }
}

- (void)shareKitPostCancel:(NTShareKit *)kit {
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:[self channelDictWithKit:kit]];
    [mutDict setObject:@0 forKey:@"code"];
    LDJSPluginResult *result =  [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsDictionary:mutDict];
    if(_callBackID && ![_callBackID isEqualToString:@""]){
        [self.commandDelegate sendPluginResult:result callbackId:_callBackID];
    }
    
}

- (void)shareKit:(NTShareKit *)kit postComplete:(NSError*)error {
    if (!error) {
        NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:[self channelDictWithKit:kit]];
        [mutDict setObject:@1 forKey:@"code"];
        LDJSPluginResult *result =  [LDJSPluginResult resultWithStatus:LDJSCommandStatus_OK messageAsDictionary:mutDict];
        if(_callBackID && ![_callBackID isEqualToString:@""]){
            [self.commandDelegate sendPluginResult:result callbackId:_callBackID];
        }
    }
}
 
- (NSDictionary *)channelDictWithKit:(NTShareKit *)kit{
    NSDictionary *dic = nil;
    if ([kit isKindOfClass:[NTShareKitWX class]]) {
        if (((NTShareKitWX *)kit).toFriends) {
            dic = @{@"channel":@"weixin_timeline"};
        }else{
            dic = @{@"channel":@"weixin_session"};
        }
    }else if([kit isKindOfClass:[NTShareKitYX class]]){
        if (((NTShareKitYX *)kit).toFriends) {
            dic = @{@"channel":@"yixin_timeline"};
        }else{
            dic = @{@"channel":@"yixin_session"};
        }
    }else if([kit isKindOfClass:[NTShareKitQQ class]]){
        if (((NTShareKitQQ *)kit).toFriends) {
            dic = @{@"channel":@"QZONE"};
        }else{
            dic = @{@"channel":@"QQ"};
        }
    }else if([kit isKindOfClass:[NTShareKitWeibo class]]){
        dic = @{@"channel":@"weibo"};
    }
    return dic;
}
*/
 

@end
