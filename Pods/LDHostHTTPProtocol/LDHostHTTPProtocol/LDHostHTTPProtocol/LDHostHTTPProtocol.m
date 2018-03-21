//
//  LDHostHTTPProtocol.m
//  movie163
//
//  Created by Magic Niu on 14-10-10.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "LDHostHTTPProtocol.h"

#import "CanonicalRequest.h"
#import "CacheStoragePolicy.h"

static BOOL kPreventOnDiskCaching = NO;

@interface LDHostHTTPProtocol ()

@property (atomic, strong, readwrite) NSThread *                        clientThread;

@property (atomic, copy,   readwrite) NSArray *                         modes;              // see below
@property (atomic, assign, readwrite) NSTimeInterval                    startTime;          // written by client thread only, read by any thread
@property (atomic, strong, readwrite) NSURLRequest *                    actualRequest;      // client thread only
@property (atomic, strong, readwrite) NSURLConnection *                 connection;         // client thread only
@property (atomic, strong) NSURLResponse *response;
@property (atomic, strong) NSError *error;

@end

@implementation LDHostHTTPProtocol

@synthesize modes            = _modes;
@synthesize startTime        = _startTime;
@synthesize clientThread     = _clientThread;
@synthesize actualRequest    = _actualRequest;
@synthesize connection       = _connection;

#pragma mark * Subclass specific additions

static NSDictionary *hostMaps;          // protected by @synchronized on the class

+ (void)start
// See comment in header.
{
    [NSURLProtocol registerClass:self];
}

+ (NSDictionary *)hostMaps
// See comment in header.
{
    NSDictionary *result;
    
    @synchronized (self) {
        result = hostMaps;
    }
    return result;
}

+ (void)setHostMaps:(NSDictionary *)newHostMaps
// See comment in header.
{
    @synchronized (self) {
        hostMaps = newHostMaps;
    }
}

#pragma mark * NSURLProtocol overrides

static NSString * kOurRequestProperty = @"com.apple.dts.LDHostHTTPProtocol";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
    // An override of an NSURLProtocol method.  We claim all HTTPS requests that don't have 
    // kOurRequestProperty attached.
    //
    // This can be called on any thread, so we have to be careful what we touch.
{
    BOOL        result;
    NSURL *     url;
    NSString *  scheme;
    
    url = [request URL];
    assert(url != nil);     // The code won't crash if url is nil, but we still want to know at debug time.
    
    if (url.host.length <= 0 || hostMaps.count <= 0) {
        return NO;
    }
    
    //Ignore the url not in host maps
    if (!hostMaps[url.host]) {
        return NO;
    }
    
    result = ([self propertyForKey:kOurRequestProperty inRequest:request] == nil);
    if (result) {
        scheme = [[url scheme] lowercaseString];
        assert(scheme != nil);
        
        result = [scheme isEqual:@"https"];
        
        // Flip the following to YES to have all requests go through the custom protocol.
        
        if (!result) {
            result = [scheme isEqual:@"http"];
        }
    }
    
    return result;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
    // An override of an NSURLProtocol method.   Canonicalising a request is quite complex, 
    // so all the heavy lifting has been shuffled off to a separate module.
    //
    // This can be called on any thread, so we have to be careful what we touch.
{
    NSURLRequest *result = CanonicalRequestForRequest(request);
    return result;
}

- (void)dealloc
    // This can be called on any thread, so we have to be careful what we touch.
{
    assert(self->_actualRequest == nil);            // we should have cleared it by now
    assert(self->_connection == nil);               // we should have cancelled it by now
}

- (void)startLoading
    // An override of an NSURLProtocol method.   At this point we kick off the process 
    // of loading the URL via NSURLConnection.
    //
    // The thread that this is called on becomes the client thread.
{
    NSMutableURLRequest *   newRequest;
    NSString *              currentMode;
    
    assert(self.clientThread == nil);           // you can't call -startLoading twice
    assert(self.connection == nil);
    
    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at
    // you UIWebView!) we can be called from a non-standard thread which then runs a
    // non-standard run loop mode waiting for the request to finish.  We detect this
    // non-standard mode and add it to the list of run loop modes we use when scheduling
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode"
    // but it's better not to hard-code that here.
    
    assert(self.modes == nil);
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( [currentMode isEqual:NSDefaultRunLoopMode] ) {
        currentMode = nil;
    }
    self.modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, currentMode, nil];
    assert([self.modes count] > 0);
    
    // Create new request that's a clone of the request we were initialised with,
    // except that it has our custom property set on it.
    
    newRequest = [[self request] mutableCopy];
    assert(newRequest != nil);
    [[self class] setProperty:@YES forKey:kOurRequestProperty inRequest:newRequest];
    [self confHostForRequest:newRequest];

    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    
    // Now create a connection with the new request.  Don't start it immediately because
    // a) if we start immediately our delegate can be called before -initWithRequest:xxx
    // returns, and that confuses our asserts, and b) we want to customise the run loop modes.
    
    self.connection = [[NSURLConnection alloc] initWithRequest:newRequest delegate:self startImmediately:NO];
    assert(self.connection != nil);
    
    for (NSString * mode in self.modes) {
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
    }
    
    // Latch the actual request we sent down so that we can use it for cache storage
    // policy determination.
    
    self.actualRequest = newRequest;
    
    // Latch the thread we were called on, primarily for debugging purposes.
    
    self.clientThread = [NSThread currentThread];
    
    // Once everything is ready to go, start the request.
    
    [self.connection start];
}

- (void)stopLoading
    // An override of an NSURLProtocol method.   We cancel our load.
    //
    // Expected to be called on the client thread.
{
    assert(self.clientThread != nil);           // someone must have called -startLoading
    
    // Check that we're being stopped on the same thread that we were started
    // on.  Without this invariant things are going to go badly (for example,
    // run loop sources that got attached during -startLoading may not get
    // detached here).
    //
    // I originally had code here to skip over to the client thread but that
    // actually gets complex when you consider run loop modes, so I've nixed it.
    // Rather, I rely on our client calling us on the right thread, which is what
    // the following assert is about.
    
    assert([NSThread currentThread] == self.clientThread);
    
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    
    self.actualRequest = nil;
    // Don't nil out self.modes; see the comment near the property declaration for a
    // a discussion of this.
}

- (void)confHostForRequest:(NSMutableURLRequest *)newRequest {
    if (hostMaps.count > 0) {
        NSString *urlString = newRequest.URL.absoluteString;
        __block NSString *newUrlString = urlString;
        [hostMaps enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([newUrlString rangeOfString:key].length>0) {
                newUrlString = [newUrlString stringByReplacingOccurrencesOfString:key withString:obj];
                *stop = YES;
                [newRequest setURL:[NSURL URLWithString:newUrlString]];
                [newRequest setValue:key forHTTPHeaderField:@"HOST"];
            }
        }];
    }
}

#pragma mark * NSURLConnection delegate callbacks

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
    // An NSURLConnection delegate callback.  We use this to tell the client about redirects 
    // (and for a bunch of debugging and logging).
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(request != nil);
    // response may be nil
    
    assert([NSThread currentThread] == self.clientThread);
    
    if (response) {
        NSMutableURLRequest *redirectRequest;
        
        // The new request was copied from our old request, so it has our magic property.  We actually
        // have to remove that so that, when the client starts the new request, we see it.  If we
        // don't do this then we never see the new request and thus don't get a chance to change
        // its caching behaviour.
        //
        // We also cancel our current connection because the client is going to start a new request for
        // us anyway.
        
        assert([[self class] propertyForKey:kOurRequestProperty inRequest:request] != nil);
        
        redirectRequest = [request mutableCopy];
        [[self class] removePropertyForKey:kOurRequestProperty inRequest:redirectRequest];
        
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
        
        [self.connection cancel];
        [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
    return request;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    self.response = response;
    
    #pragma unused(connection)
    NSURLCacheStoragePolicy cacheStoragePolicy;
    
    assert(connection == self.connection);
    assert(response != nil);
    
    assert([NSThread currentThread] == self.clientThread);
    
    // Pass the call on to our client.  The only tricky thing is that we have to decide on a
    // cache storage policy, which is based on the actual request we issued, not the request
    // we were given.
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(self.actualRequest, (NSHTTPURLResponse *) response);
    } else {
        assert(NO);
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
    }
    
    // If we're forcing in in-memory caching only, override the cache storage policy.
    if (kPreventOnDiskCaching) {
        if (cacheStoragePolicy == NSURLCacheStorageAllowed) {
            cacheStoragePolicy = NSURLCacheStorageAllowedInMemoryOnly;
        }
    }
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(cachedResponse != nil);
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(data != nil);
    
    assert([NSThread currentThread] == self.clientThread);
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    
    assert([NSThread currentThread] == self.clientThread);
    
    // Just pass the call on to our client.
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
    // An NSURLConnection delegate callback.  We pass this on to the client.
    //
    // Runs on the client thread.
{
    #pragma unused(connection)
    assert(connection == self.connection);
    assert(error != nil);
    
    assert([NSThread currentThread] == self.clientThread);
    
    self.error = error;
    
    // Just pass the call on to our client.
    [[self client] URLProtocol:self didFailWithError:error];
}

@end
