//
//  NIPModelObject.h
//  ModelCoder
//
//  Created by  龙会湖 on 14-9-28.
//  Copyright (c) 2014年 longhuihu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIPModelObject <NSObject>
- (id)initWithJSON:(NSDictionary*)dict;
@end
