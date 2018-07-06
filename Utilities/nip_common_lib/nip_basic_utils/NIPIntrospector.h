//
//  NIPIntrospector.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  NIPIntrospector用来对oc类型进行反射，以及其他运行时方法
 */
@interface NIPIntrospector : NSObject
/**
 *  获取类cls所有的成员变量信息
 *
 *  @param cls
 *
 *  @return 所有成员变量描述组成的数组，每个变量描述的格式是<offset-偏移量，name-变量名字, type-变量的类型编码>
 */
+ (NSArray *)getIvarsFromClass:(Class)cls;


//类似getIvarsFromClass,不同的是会包含基类的成员变量信息
+ (NSDictionary *)getIvarsFromClassCascaded :(Class)cls;

/// 进行方法交换
+ (void)swizzleMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel;

@end
