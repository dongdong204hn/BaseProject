//
//  NIPJSCommandQueue.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSCommandQueue.h"
#import "NIPJSService.h"
#import "NIPJSJSON.h"
#import "NIPJSQueue.h"
#import "NIPJSPlugin.h"
#import "NIPJSInvokedURLCommand.h"

#import <objc/runtime.h>
#import <objc/message.h>


//启用主线程执行最小command长度
static const NSInteger JSON_SIZE_FOR_MAIN_THREAD = 4 * 1024;
//一次执行命令的最长允许执行时间
static const double MAX_EXECUTION_TIME = .008;  // Half of a 60fps frame.

@interface NIPJSCommandQueue ()

@property (nonatomic, weak) NIPJSService *JSService;
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, assign) NSTimeInterval startExecutionTime;

@end


@implementation NIPJSCommandQueue


- (void)dealloc {
    _JSService = nil;
    [_queue removeAllObjects];
    _queue = nil;
}

- (instancetype)initWithService:(NIPJSService *)JSService {
    self = [super init];
    if (self) {
        _JSService = JSService;
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dispose {
    _JSService = nil;
}

- (BOOL)isExecutingCMD {
    return _startExecutionTime > 0;
}

- (void)executeCommandsFromURLString:(NSString *)URLString {
    NSURL *commandURL = [NSURL URLWithString:URLString];
    
    NSString *host = commandURL.host;
    NSString *path = commandURL.path;
    NSString *query = commandURL.query;
    NSString *fragment = commandURL.fragment;
    
    //获取url回调函数的index
    __block NSString *callIndex = @"";
    if (fragment &&
        ![fragment isEqualToString:@""] &&
        [fragment intValue] > 0) {
        callIndex = fragment;
    }
    
    //获取调用插件名
    NSString *pluginName = @"";
    if (host && ![host isEqualToString:@""]) {
        pluginName = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)host, CFSTR(""), kCFStringEncodingUTF8));
    }
    
    //获取调用方法名，规定第一个path为方法名
    NSString *methodShowName = @"";
    if (path && ![path isEqualToString:@""]) {
        NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
        if (pathComponents &&
            pathComponents.count >= 2 &&
            [pathComponents[0] isEqualToString:@""] &&
            ![pathComponents[1] isEqualToString:@""]) {
            methodShowName = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)[pathComponents objectAtIndex:1], CFSTR(""), kCFStringEncodingUTF8));
        }
    }
    
    //获取通过URL query对象传进来的参数
    NSMutableArray *paramsArray = nil;
    if (query && query.length > 0) {
        NSArray *queryParams = [query componentsSeparatedByString:@"&"];
        if (queryParams && queryParams.count > 0) {
            paramsArray = [[NSMutableArray alloc] initWithCapacity:queryParams.count];
            for (NSString *paramPair in queryParams) {
                //分割参数,每一个参数都进行了URLDecode
                NSArray *paramPairs = [paramPair componentsSeparatedByString:@"="];
                if (paramPairs.count == 2) {
                    NSString *paramString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)paramPairs[1], CFSTR(""), kCFStringEncodingUTF8));
                    [paramsArray addObject:paramString];
                }
            }
        }
    }
    
    // 遍历参数数组，检查JSON参数, 记录JSON参数供使用
    NSMutableDictionary *paramsDic = nil;
    if (paramsArray && paramsArray.count > 0) {
        NSMutableArray *paramsToDelete = [NSMutableArray array];
        for (NSString *paramStr in paramsArray) {
            NSDictionary *tmpParamsDic = (NSDictionary *)[paramStr cdv_JSONObject];
            if (tmpParamsDic == nil) {
                continue;
            }
            if ([tmpParamsDic allKeys].count > 0 && paramsDic == nil) {
                paramsDic = [[NSMutableDictionary alloc] initWithCapacity:2];
            }
            
            // 遍历JSON参数
            [tmpParamsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([[key lowercaseString] isEqualToString:@"callback"]) {
                    callIndex = obj;
                }
                [paramsDic setObject:obj forKey:key];
            }];
            
            //从param中删除参数
            [paramsToDelete addObject:paramStr];
        }
        for (NSString *paramStr in paramsToDelete) {
            [paramsArray removeObject:paramStr];
        }
    }
    
    // 组装数组参数arguments
    __block NSString *argumentsString = @"";
    [paramsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSArray class]] ||
            [obj isKindOfClass:[NSDictionary class]]) {
            obj = [obj cdv_JSONString];
            obj = [obj stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            obj = [obj stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
        }
        argumentsString = [argumentsString stringByAppendingFormat:@"\"%@\"%@", obj, idx == paramsArray.count - 1 ? @"" : @","];
    }];
    
    // 组装JSON参数
    NSString *JSONParamString = @"";
    if (paramsDic) {
        JSONParamString = [paramsDic cdv_JSONString];
        JSONParamString = [JSONParamString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    //组装command
    NSString *queuedCommandsJSON = [NSString stringWithFormat:@"[[\"%@\",\"%@\",\"%@\",[%@],[%@]]]", callIndex, pluginName, methodShowName, argumentsString ?: @"",  JSONParamString ?: @""];
    [self enqueueCommandBatch:queuedCommandsJSON];
}


- (void)enqueueCommandBatch:(NSString *)batchJSON {
    if ([batchJSON length] > 0) {
        NSMutableArray *commandBatchHolder = [[NSMutableArray alloc] init];
        [_queue addObject:commandBatchHolder];
        if ([batchJSON length] < JSON_SIZE_FOR_MAIN_THREAD) {
            [commandBatchHolder addObject:[batchJSON cdv_JSONObject]];
            [self executePending];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
                NSMutableArray *result = [batchJSON cdv_JSONObject];
                @synchronized(commandBatchHolder)
                {
                    [commandBatchHolder addObject:result];
                }
                [self performSelectorOnMainThread:@selector(executePending)
                                       withObject:nil
                                    waitUntilDone:NO];
            });
        }
    }
}


- (void)executePending {
    if (_startExecutionTime > 0) {
        return;
    }
    @try {
        _startExecutionTime = [NSDate timeIntervalSinceReferenceDate];
        while ([_queue count] > 0) {
            NSMutableArray *commandBatchHolder = _queue[0];
            NSMutableArray *commandBatch = nil;
            @synchronized(commandBatchHolder)
            {
                if ([commandBatchHolder count] == 0) {
                    break;
                }
                commandBatch = commandBatchHolder[0];
            }
            
            while ([commandBatch count] > 0) {
                @autoreleasepool
                {
                    NSArray *jsonEntity = [commandBatch cdv_dequeue];
                    if ([commandBatch count] == 0) {
                        [_queue removeObjectAtIndex:0];
                    }
                    NIPJSInvokedURLCommand *command =
                    [NIPJSInvokedURLCommand commandFromJSON:jsonEntity];
                    if (![self execute:command]) {
                        NSLog(@"Exec(%@) failure: Calling %@.%@", command.callbackId,
                              command.pluginName, command.pluginShowMethod);
                    }
                }
                
                //如果当前有多个命令，当前命令执行太久，不再继续执行命令
                if (([_queue count] > 0) &&
                    ([NSDate timeIntervalSinceReferenceDate] - _startExecutionTime >
                     MAX_EXECUTION_TIME)) {
                        [self performSelector:@selector(executePending) withObject:nil afterDelay:0];
                        return;
                    }
            }
        }
    } @finally {
        _startExecutionTime = 0;
    }
}


- (BOOL)execute:(NIPJSInvokedURLCommand *)command {
    if ((command.pluginName == nil) || (command.pluginShowMethod == nil)) {
        NSLog(@"ERROR: pluginName and/or pluginShowMethod not found for command.");
        return NO;
    }
    
    // 从当前BridgeService中的插件管理器中获取插件实例
    NIPJSPlugin *obj = [_JSService getPluginInstanceWithName:command.pluginName];
    if (!obj || !([obj isKindOfClass:[NIPJSPlugin class]])) {
        NSLog(@"ERROR: Plugin '%@' not found, or is not a LDJSPlugin. Check your plugin mapping in "
              @"PluginConfig.json.",
              command.pluginName);
        return NO;
    }
    
    BOOL retVal = YES;
    double started = [[NSDate date] timeIntervalSince1970] * 1000.0;
    SEL normalSelector =
    NSSelectorFromString([_JSService realSELForShowMethod:command.pluginShowMethod]);
    if (normalSelector && [obj respondsToSelector:normalSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(obj, normalSelector, command);
    } else {
        NSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", command.pluginShowMethod,
              command.pluginName);
        retVal = NO;
    }
    double elapsed = [[NSDate date] timeIntervalSince1970] * 1000.0 - started;
    if (elapsed > 2 * 1000.0) {
        NSLog(@"THREAD WARNING: ['%@'] took '%f' ms. Plugin should use a background thread.",
              command.pluginName, elapsed);
    }
    return retVal;
}

@end
