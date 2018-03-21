//
//  NIPTextActivityIndicator.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  一个包含文字+UIActivityIndicator的view
 */
@interface NIPTextActivityIndicator : NIPView {
    UIActivityIndicatorView *_indicator;
    UILabel  *_label;
    BOOL _animating;
}
@property(nonatomic,readonly) UILabel *label;
@property(nonatomic) BOOL delayMode;

-(id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style 
                               text:(NSString*)text;
-(void)show;
-(void)resizeToContent;
@end
