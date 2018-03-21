//
//  NIPJSPluginInfo.m
//  NIPJSBridge
//
//  Created by Eric on 2017/4/12.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "NIPJSPluginInfo.h"
#import "NIPJSExportDetail.h"
#import "NIPJSPlugin.h"

@implementation NIPJSPluginInfo

- (instancetype)initWithPluginInfo:(NSDictionary *)pluginInfo {
    self = [super init];
    if (self) {
        self.pluginName = pluginInfo[@"pluginName"];
        self.pluginClass = pluginInfo[@"pluginClass"];
        
        NSMutableDictionary *exports = [[NSMutableDictionary alloc] init];
        for (NSDictionary *exportInfo in pluginInfo[@"exports"]) {
            NIPJSExportDetail *exportDetail = [[NIPJSExportDetail alloc] initWithExportInfo:exportInfo];
            [exports setObject:exportDetail forKey:exportDetail.showMethod];
        }
        self.exports = exports;
        
        Class pluginClass = NSClassFromString(self.pluginClass);
        if (pluginClass) {
            id pluginInstance = [[pluginClass alloc] init];
            if (pluginInstance) {
                [pluginInstance pluginInitialize];
                self.instance = pluginInstance;
            } else {
                NSLog(@"plugin initialize failed with name: %@", self.pluginClass);
            }
        } else {
            NSLog(@"plugin class: %@'with name: %@ does not exist.", self.pluginClass, self.pluginName);
        }
    }
    
    return self;
}

- (NIPJSExportDetail *)getDetailByShowMethod:(NSString *)showMethod {
    NIPJSExportDetail *export = self.exports[showMethod];
    return export;
}

@end
