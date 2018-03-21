//
//  NIPAlertView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^AlertDismissBlock)(NSInteger buttonIndex);

/**
 *  NIPAlertView为alertView/alertController 的封装 ios7用uialertview，iOS8及以上用uialertController
 */
@interface NIPAlertView : NSObject

+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;

+ (void)simpleAlertWithTitle:(NSString *)title
                     message:(NSString *)message
                   onDismiss:(AlertDismissBlock)dismissBlock;
+ (void)warmAlertWithTitle:(NSString *)title
                     message:(NSString *)message
                   onDismiss:(AlertDismissBlock)dismissBlock;
+ (void)questionAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                     onDismiss:(AlertDismissBlock)dismissBlock;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;


@property (nonatomic, copy) AlertDismissBlock onDismissBlock;



@end


