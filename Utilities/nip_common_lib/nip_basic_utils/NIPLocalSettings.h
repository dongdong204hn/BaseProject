//
//  NIPLocalSettings.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NIP_SETTER_GETTER_BOOL(name,cname) \
-(BOOL)name {\
NSNumber *number = [self.settingsDic objectForKey:@#name];\
if (number == nil) {\
return  NO;\
}\
return number.boolValue;\
}\
-(void)set##cname:(BOOL)value {\
if (value!=self.name) {\
NSNumber *number = [NSNumber numberWithBool:value];\
[self setSettingValue:number forKey:@#name];\
}\
}

#define  NIP_SETTER_GETTER_INTEGER(name,cname) \
-(NSInteger)name {\
NSNumber *number = [self.settingsDic objectForKey:@#name];\
if (number == nil) {\
return  0;\
}\
return number.integerValue;\
}\
-(void)set##cname:(NSInteger)value {\
if (value!=self.name) {\
NSNumber *number = [NSNumber numberWithInteger:value];\
[self setSettingValue:number forKey:@#name];\
}\
}

#define  NIP_SETTER_GETTER_LONG(name,cname) \
-(long)name {\
NSNumber *number = [self.settingsDic objectForKey:@#name];\
if (number == nil) {\
return  0;\
}\
return number.longValue;\
}\
-(void)set##cname:(long)value {\
if (value!=self.name) {\
NSNumber *number = [NSNumber numberWithLong:value];\
[self setSettingValue:number forKey:@#name];\
}\
}

#define  NIP_SETTER_GETTER_DOUBLE(name,cname) \
-(double)name {\
NSNumber *number = [self.settingsDic objectForKey:@#name];\
if (number == nil) {\
return  0;\
}\
return number.doubleValue;\
}\
-(void)set##cname:(double)value {\
if (value!=self.name) {\
NSNumber *number = [NSNumber numberWithDouble:value];\
[self setSettingValue:number forKey:@#name];\
}\
}


#define  NIP_SETTER_GETTER_OBJECT(name,cname,type) \
-(type*)name {\
return [self.settingsDic objectForKey:@#name];\
}\
-(void)set##cname:(type*)value {\
if (!value) {\
[self removeSettingValueForKey:@#name];\
} else {\
[self setSettingValue:value forKey:@#name];\
}\
}

/**
 *  一个基于NSDefault的本地配置项支持类，继承者通过使用上面定义的宏，可以快速定义配置项的getter&setter。请勿存储未实现NSCoding协议的类的对象。
 */
@interface NIPLocalSettings : NSObject

@property (nonatomic, strong) NSMutableDictionary *settingsDic;

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *idfv;
@property (nonatomic, strong) NSString *idfa;

+ (instancetype)settings;

- (id)settingValueForKey:(NSString *)key;

- (void)setSettingValue:(NSObject*)value forKey:(NSString*)key;
- (void)removeSettingValueForKey:(NSString*)key;

@end
