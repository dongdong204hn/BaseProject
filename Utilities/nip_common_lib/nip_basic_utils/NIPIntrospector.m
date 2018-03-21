//
//  NIPIntrospector.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <objc/runtime.h>
#import "NIPIntrospector.h"

#define IVAR_TYPE_LENGTH_LIMIT 50

@implementation NIPIntrospector

+ (NSArray *)getIvarsFromClass:(Class)cls {
    NSMutableArray *varArray = [NSMutableArray array];

    unsigned int ivarsCnt = 0;

    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if (type.length>IVAR_TYPE_LENGTH_LIMIT) {
            type = [type substringToIndex:IVAR_TYPE_LENGTH_LIMIT];
            type = [type stringByAppendingString:@"..."];
        }
        size_t offset = ivar_getOffset(ivar);
        [varArray addObject:[NSString stringWithFormat:@"<%ld,%@,%@>",offset,key,type]];
    }
    return varArray;
}

+ (NSDictionary *)getIvarsFromClassCascaded :(Class)cls {
    NSMutableDictionary *classVarDictionary = [NSMutableDictionary dictionary];
    
    NSMutableArray *clsHierarchArray = [NSMutableArray array];
    while (cls) {
        [clsHierarchArray addObject:cls];
        cls = [cls superclass];
    }
    
    //之所以给每个class名称前加个数字，是确保NSlog(classVarDictionary)按类的层级顺序输出
    [clsHierarchArray enumerateObjectsWithOptions:0
                                       usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                           Class clsObj = obj;
                                           idx = clsHierarchArray.count - idx;
                                           [classVarDictionary setObject:[self getIvarsFromClass:clsObj]
                                                                  forKey:[NSString stringWithFormat:@"%ld-%@",(long)idx,NSStringFromClass(clsObj)]];
                                       }];
    
    return classVarDictionary;
}

+ (void)swizzleMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel {
    
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method swizMethod = class_getInstanceMethod(class, swizSel);
    
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

@end
