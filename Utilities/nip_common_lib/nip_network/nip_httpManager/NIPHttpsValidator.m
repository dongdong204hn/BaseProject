//
//  NTHttpsValidator.m
//  trainTicket
//
//  Created by zhao on 14-6-5.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NIPHttpsValidator.h"

@implementation NIPHttpsValidator {
    /**
     *  是否正在验证_trustArray中的全部host
     */
    BOOL _isValidatingUntrustHostArray;
    
    /**
     *  可信host列表
     */
    NSMutableArray *_trustArray;
    
    /**
     *  不可信host列表
     */
    NSMutableArray *_untrustArray;
}

+ (instancetype)shareValidator {
    static NIPHttpsValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIPHttpsValidator alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _trustArray = [NSMutableArray array];
//    TODO:_untrustArray需要重新指定
        _untrustArray = [NSMutableArray arrayWithObjects:@"epay.12306.cn",@"mapi.alipay.com",@"wappaygw.alipay.com",@"ynuf.alipay.com",@"mrmoaprod.alipay.com",
                         @"mrexcashier.alipay.com",@"qr.alipay.com",@"mobilecodec.alipay.com",nil];
    }
    return self;
}

- (void)addTrustHostString:(NSString *)hostString {
    [_trustArray addObject:hostString];
    if ([_untrustArray containsObject:hostString]) {
        [_untrustArray removeObject:hostString];
    }
}

- (void)validateUntrustHostArray {
    if (_untrustArray.count) {
        _isValidatingUntrustHostArray = YES;
        [self validateUntrustHostString:[_untrustArray objectAtIndex:0]];
    } else {
        _isValidatingUntrustHostArray = NO;
    }
}

- (BOOL)isHostStringBeTrusted:(NSString *)hostString {
    if ([_trustArray containsObject:hostString]) {
        return YES;
    }
    return NO;
}

- (void)validateUntrustHostString:(NSString *)hostString {
//    LOG(@"validate host: %@", hostString);
    NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@",hostString]];
    NSURLConnection *authConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:authUrl]
                                                    delegate:self];
    [authConnection start];
}

#pragma mark - NURLConnection delegate


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
//    LOG(@"Validator Got auth challange at %@",connection.currentRequest.URL.host);
    if ([challenge previousFailureCount] ==0)
    {
        [self addTrustHostString:[connection.originalRequest.URL host]];
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    } else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    LOG(@"Validator received response at %@",connection.currentRequest.URL.host);
    // remake a webview call now that authentication has passed ok.
    [self addTrustHostString:[connection.originalRequest.URL host]];
    [connection cancel];
    if ([_delegate respondsToSelector:@selector(validateHttpsHostStringSuccess:)]) {
        [_delegate validateHttpsHostStringSuccess:connection.currentRequest.URL.host];
    }
    if (_isValidatingUntrustHostArray) {
        [self validateUntrustHostArray];
    }
}


// We use this method is to accept an untrusted site which unfortunately we need to do, as our PVM servers are self signed.

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

@end
