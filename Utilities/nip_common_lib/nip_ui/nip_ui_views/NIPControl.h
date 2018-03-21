//
//  NIPControl.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIPViewProtocol.h"
#import "nip_ui_util.h"
#import "nip_ui_additions.h"

/**
 *  自定义代码库里面control类控件的基类
 */
@interface NIPControl : UIControl<NIPViewProtocol> {
@protected
    UIImageView *_backgroundView;
}

@end
