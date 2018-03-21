//
//  NIPActionSheet.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionSheetBlock)(NSInteger buttonIndex);

/**
 *  NIPActionSheet为UIActionSheet提供block支持
 */
@interface NIPActionSheet : NSObject


@property (nonatomic, copy) ActionSheetBlock dismissBlock;


- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle  andButtons:(NSArray*)buttons;

- (void)showInController:(UIViewController *)controller;


@end
