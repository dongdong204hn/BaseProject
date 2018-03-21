//
//  NIPURLRouter.h
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPURLRouter : NSObject


+ (instancetype)sharedRouter;


- (BOOL)openURL:(NSURL *)url baseViewController:(UIViewController *)baseViewController;

@end
