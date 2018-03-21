//
//  NIPAction.h
//  NSIP
//
//  Created by 赵松 on 16/12/26.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

//Action用来封装某种动作，该设计参考设计模式COMMAND
//Action实例执行时会被放置进一个队列，执行完之后自动从队列移除，因此调用者可以不关注Action的生命周期；

@interface NIPAction : NSObject

@property(nonatomic) BOOL singleAction; //对于同类型的action，只允许有一个存在

- (void)execute;
- (void)setComplete;
- (void)main;
@end
