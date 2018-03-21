//
//  NIPKeyValue.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  实现一个key value pair
 */
@interface NIPKeyValue : NSObject
@property(nonatomic,strong) id key;
@property(nonatomic,strong) id value;
- (id)initWithKey:(id)key andValue:(id)value;
@end
