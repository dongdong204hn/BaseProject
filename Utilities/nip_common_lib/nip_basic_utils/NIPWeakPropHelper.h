//
//  NIPWeakPropHelper.h
//  NSIP
//
//  Created by 赵松 on 2018/6/12.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef void(^NIPDeallocBlock)();

@interface NIPWeakPropHelper : NSObject

+ (instancetype)helperWithDeallocBlock:(NIPDeallocBlock)block;

@end

/**
 通过分类添加weak属性

 @param aName 获取
 @param aSetter setter方法名
 @param aType 类型

 使用例子
 @interface MyObject(NIPWeakProp)
 @property (nonatomic, weak) B *weakObject;
 @end
 
 @implementation MyObject(NIPWeakProp)
 RuntimeWeakImpl(weakObject, setWeakObject, B *);
 @end

 使用
 MyObject.weakObject = [B new];
 当Ａ或Ｂ被释放时，会清除相应的数据
 */
#define NIPWeakProperty(aName, aSetter, aType)                                  \
- (aType)aName{                                                                 \
    const void *key = class_getInstanceMethod([self class], @selector(aName));  \
    return objc_getAssociatedObject(self, key);                                 \
}                                                                               \
- (void)aSetter:(id)aWeakObject {                                                                           \
    id previousWeakObject = [self aName];                                                                   \
    if (previousWeakObject != aWeakObject) {                                                                \
        const void *key = class_getInstanceMethod([self class], @selector(aName));                          \
        const void *clearAssObjKey = class_getInstanceMethod([self class], @selector(aSetter:));            \
        if (previousWeakObject) {                                                                           \
            NIPWeakPropHelper *assObj = objc_getAssociatedObject(previousWeakObject, key);             \
            if (assObj && [assObj isKindOfClass:[NIPWeakPropHelper class]]) {                          \
                objc_setAssociatedObject(previousWeakObject, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  \
            }                                                                                               \
        }                                                                                                   \
        if (aWeakObject) {                                                                                  \
            __weak typeof(self) pWeakSelf = self;                                                           \
            __weak typeof(aWeakObject) pWeakObject = aWeakObject;                                           \
            objc_setAssociatedObject(self, key, aWeakObject, OBJC_ASSOCIATION_ASSIGN);                      \
            NIPWeakPropHelper *obj = [NIPWeakPropHelper helperWithDeallocBlock:^{                                 \
                __strong typeof(pWeakSelf) pSelf = pWeakSelf;                                               \
                if (pSelf){                                                                                 \
                    objc_setAssociatedObject(pSelf, key, nil, 0);                                           \
                    objc_setAssociatedObject(pSelf, clearAssObjKey, nil, 0);                                \
                }                                                                                           \
            }];                                                                                             \
            objc_setAssociatedObject(aWeakObject, key, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);             \
            obj = [NIPWeakPropHelper helperWithDeallocBlock:^{                                                         \
                __strong typeof(pWeakObject) pObject = pWeakObject;                                         \
                if (pObject){                                                                               \
                    objc_setAssociatedObject(pObject, key, nil, 0);                                         \
                }                                                                                           \
            }];                                                                                             \
            objc_setAssociatedObject(self, clearAssObjKey, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);         \
        }                                                                                                   \
    }                                                                                                       \
}
