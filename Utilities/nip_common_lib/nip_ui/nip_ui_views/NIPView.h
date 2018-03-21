//
//  NIPView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIPViewProtocol.h"
#import "nip_ui_additions.h"
#import "nip_ui_util.h"

/**
 *  这个代码库里面自定义view类的基类
 */
@interface NIPView : UIView<NIPViewProtocol> {
@protected
    UIView *_backgroundView;
}

-(void)resizeToContent;

@end
