//
//  NIPLayoutable.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIPLayoutable <NSObject>
@property(nonatomic) BOOL dontAutoResizeInLayout;
@property(nonatomic) UIEdgeInsets contentEdgeInsets;

-(void)resizeToContent;
@end
