//
//  NIPKeychain.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

@interface NIPKeychain : NSObject

/**
 *  保存data为keychain
 *
 *  @param data       需保存的数据
 *  @param identifier 在keychian中的标识
 *
 *  @return 成功为YES
 */
+ (BOOL)saveKeychain:(id)data forIdentifier:(NSString *)identifier;
/**
 *  查找keychain
 *
 *  @param identifier 标识
 *
 *  @return 保存的数据
 */
+ (id)findKeychain:(NSString *)identifier;
/**
 *  delete
 *
 *  @param identifier 标识
 */
+ (void)deleteKeychain:(NSString *)identifier;

@end
