//
//  URSRequest.m
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#import "URSRequest.h"
#import "NSString+URS.h"
//#import "version.h"

@interface URSRequest ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString *statusDescription;
@end

@implementation URSRequest
{
    NSInteger _statusCode;
}

@synthesize delegate = _delegate;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize statusDescription = _statusDescription;

+ (URSRequest *)reqquest
{
    URSRequest *request = [[URSRequest alloc] init];
    return URS_AUTORELEASE(request);
}

+ (NSString *)paramatersWithDictionary:(NSDictionary *)params
{
    NSMutableString *paramStringBuffer = [NSMutableString string];
    NSEnumerator *keys = [params keyEnumerator];
    for (NSString *key in keys) {
        NSString *value = [params objectForKey:key];
        [paramStringBuffer appendString:[key urs_URLEncodedString]];
        [paramStringBuffer appendString:@"="];
        [paramStringBuffer appendString:[value urs_URLEncodedString]];
        [paramStringBuffer appendString:@"&"];
    }

    NSString *paramString = paramStringBuffer;
    if ([paramString length] > 0) {
        paramString = [paramString substringToIndex:paramString.length - 1];
    }
    return paramString;
}

- (void)postWithUrl:(NSString *)url
           andParam:(NSDictionary *)params
{
    [self cancel];

    NSMutableString *paramStringBuffer = [NSMutableString string];
    NSEnumerator *keys = [params keyEnumerator];
    for (NSString *key in keys) {
        NSString *value = [params objectForKey:key];
        [paramStringBuffer appendString:[key urs_URLEncodedString]];
        [paramStringBuffer appendString:@"="];
        [paramStringBuffer appendString:[value urs_URLEncodedString]];
        [paramStringBuffer appendString:@"&"];
    }

    NSString *paramString = paramStringBuffer;
    if ([paramString length] > 0) {
        paramString = [paramString substringToIndex:paramString.length - 1];
    }
    NSData *requestData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10.0];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
#ifdef TEST_VERSION_
    [request setValue:@"reg.163.com" forHTTPHeaderField:@"Host"];
#endif
    [request setHTTPBody:requestData];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = URS_AUTORELEASE(connection);

    [self.connection start];
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

- (void)dealloc
{
    URS_SUPERDEALLOC
    [self cancel];
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        _statusCode = ((NSHTTPURLResponse *) response).statusCode;
        self.statusDescription = [NSHTTPURLResponse localizedStringForStatusCode:_statusCode];
        if (self.statusDescription == nil) {
            self.statusDescription = @"unknow http error";
        }
    } else {
        _statusCode = 200;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.data) {
        NSMutableData *allocData = [[NSMutableData alloc] init];
        self.data = URS_AUTORELEASE(allocData);
    }
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate request:self fail:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.data length] > 0) {
        NSString *responseString = [[NSString alloc] initWithData:self.data
                                                         encoding:NSUTF8StringEncoding];
        [self.delegate request:self
                       success:URS_AUTORELEASE(responseString)];
    } else {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:self.statusDescription
                                                         forKey:NSLocalizedDescriptionKey];
        [self.delegate request:self fail:[NSError errorWithDomain:@"URS_AUTH"
                                                             code:_statusCode
                                                         userInfo:dict]];
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

//two deprecated api for lower version ios
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

@end
