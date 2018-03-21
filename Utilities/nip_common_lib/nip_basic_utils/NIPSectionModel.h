//
//  NIPSectionModel.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 用于为UITableView dataSource提供便利，封装section数据
 */
@interface NIPSectionModel : NSObject
@property(nonatomic) NSInteger sectionTag;
@property(nonatomic) BOOL isClosed;
@property(nonatomic,strong) NSString *sectionTitle;
@property(nonatomic,strong) NSString* sectionIndexTitle;
@property(nonatomic,strong) NSArray *itemArray;
@property(nonatomic,strong) UIView *sectionHeaderView;
- (void)addItem:(NSObject*)object;
- (void)insertItem:(NSObject*)object at:(NSUInteger)index;
- (void)removeItem:(NSObject*)object;
@end
