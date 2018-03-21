//
//  NIPLocalSettings.m
//  YouHui
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPLocalSettings.h"


#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
#define LOCAL_SETTINGS @"localsettings_data"

@interface NIPLocalSettings ()

//iOS6.0之后，Dispatch objects被当做oc对象处理，6之前用assign
@property (nonatomic,strong) dispatch_queue_t persistanceQueue;

@end


@implementation NIPLocalSettings {
}

NIP_SETTER_GETTER_OBJECT(uuid, Uuid, NSString);
NIP_SETTER_GETTER_OBJECT(idfv, Idfv, NSString);
NIP_SETTER_GETTER_OBJECT(idfa, Idfa, NSString);

+ (instancetype)settings {
    static NIPLocalSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NIPLocalSettings alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.persistanceQueue = dispatch_queue_create("com.nsip.localsettings_data", NULL);
        NSData *data = [USER_DEFAULT objectForKey:LOCAL_SETTINGS];
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.settingsDic = obj;
        if (!self.settingsDic) {
            [self initData];
        }
    }
    return self;
}

- (void)initData
{
    if (!self.settingsDic) {
        self.settingsDic = [NSMutableDictionary dictionary];
    }
    else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.settingsDic];
        [USER_DEFAULT setObject:data forKey:LOCAL_SETTINGS];
        [USER_DEFAULT synchronize];
    }
}

- (id)settingValueForKey:(NSString *)key {
    __block id settingValue = nil;
    dispatch_sync(self.persistanceQueue, ^(void) {
        settingValue = [self.settingsDic valueForKey:key];
    });
    return settingValue;
}

- (void)setSettingValue:(NSObject *)value forKey:(NSString *)key
{
    dispatch_sync(self.persistanceQueue, ^(void) {
        [self.settingsDic setObject:value forKey:key];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.settingsDic];
        [USER_DEFAULT setObject:data forKey:LOCAL_SETTINGS];
        [USER_DEFAULT synchronize];
    });
}

- (void)removeSettingValueForKey:(NSString *)key
{
    dispatch_sync(self.persistanceQueue, ^(void) {
        [self.settingsDic removeObjectForKey:key];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.settingsDic];
        [USER_DEFAULT setObject:data forKey:LOCAL_SETTINGS];
        [USER_DEFAULT synchronize];
    });
}

@end
