//
//  NIPKeyboardManager.h
//  NSIP
//
//  Created by bjjiachunhui on 2017/4/26.
//  Copyright © 2017年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPKeyboardManager : NSObject


+ (BOOL)hasThirdKeyboard;

+ (void)setThirdKeyboardAvailability:(BOOL)availability;
+ (BOOL)getThirdKeyboardAvailability;

@end
