//
//  NIPViewProtocol.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPLayoutable.h"

typedef NS_ENUM(NSInteger, NIPDirection) {
    NIPDirectionLeft = 0,
    NIPDirectionRight = 1,
    NIPDirectionDown,
    NIPDirectionUp
};

/**
 *  自定义代码库里面的控件应该支持的protocol
 */
@protocol NIPViewProtocol <NIPLayoutable>
@property(nonatomic,strong) UIImage *backgroundImage;
@property(nonatomic,strong) UIView *backgroundView;
@property(nonatomic) UIEdgeInsets backgroundShadow;
@end
