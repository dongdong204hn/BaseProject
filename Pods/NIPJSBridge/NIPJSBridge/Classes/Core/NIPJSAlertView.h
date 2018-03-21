//
//  NIPJSAlertView.h
//  Pods
//
//  Created by Eric on 2017/6/20.
//
//

#import <Foundation/Foundation.h>


typedef void(^NIPAlerViewDidDismissBlock)(NSUInteger index);


@interface NIPJSAlertView : NSObject


@property (nonatomic, copy) NIPAlerViewDidDismissBlock onDismissBlock;



+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;

+ (void)simpleAlertWithTitle:(NSString *)title
                     message:(NSString *)message
                   onDismiss:(NIPAlerViewDidDismissBlock)dismissBlock;

+ (void)warmAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                 onDismiss:(NIPAlerViewDidDismissBlock)dismissBlock;

+ (void)questionAlertWithTitle:(NSString *)title
                       message:(NSString *)message
                     onDismiss:(NIPAlerViewDidDismissBlock)dismissBlock;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;


@end
