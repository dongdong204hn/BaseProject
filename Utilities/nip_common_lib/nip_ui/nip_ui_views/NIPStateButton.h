//
//  NIPStateButton.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPControl.h"

/**
 *  是UISwitch的自定义版本
 */
@interface NIPStateButton : NIPControl {
}
@property(nonatomic,strong,readonly) UILabel *textLabel;
@property(nonatomic,strong,readonly) UIImageView *imageView;
@property(nonatomic,strong) UIImage *switchOnImage;
@property(nonatomic,strong) UIImage *switchOffImage;
@property(nonatomic,strong) UIImage *switchonBackgroundImage;
@property(nonatomic,strong) UIImage *switchOffBackgroundImage;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIColor *textColorSwitchOn;
@property(nonatomic,assign) BOOL canDeselect;
@property(nonatomic) BOOL on;
@property(nonatomic,assign) UIEdgeInsets edgeInsets;
@end
