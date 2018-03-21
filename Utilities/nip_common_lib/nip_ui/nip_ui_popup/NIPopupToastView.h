//
//  NIPopupToastView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"
/**
 *  toast popup，类似Android系统里面的Toast
 */
@interface NIPopupToastView : NIPView
+ (void)showToast:(NSString*)text inController:(UIViewController*)controller;
@end
