//
//  NIPCheckBoxView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "nip_ui_layout.h"
#import "NIPControl.h"

/**
 *  CheckBox控件
 */
@interface NIPCheckBoxView : NIPControl {
    UIImageView *_checkIconView;
    UILabel *_textLabel;
    BOOL _canUnselect;
}
@property(nonatomic,readonly) UIImageView *checkIconView;
@property(nonatomic,readonly) UILabel *textLabel;
@property(nonatomic,strong) UIImage *checkIcon;
@property(nonatomic,strong) UIImage *uncheckIcon;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic,strong) UIColor *checkedTextColor;
@property(nonatomic) CGFloat iconTextSpace;
@property(nonatomic,assign) BOOL canUnselect;
@property(nonatomic) BOOL checked;

+ (NIPCheckBoxView *)checkBoxViewWithFrame:(CGRect)frame
                                     Text:(NSString *)text
                                checkIcon:(UIImage *)checkIcon
                              unCheckIcon:(UIImage *)unCheckIcon;

@end

@interface ZBCheckBoxGroup : NIPControl {
    NSMutableArray *_checkBoxArray;
    BOOL _singleCheck;
}
@property(nonatomic,assign) BOOL singleCheck;
@property(nonatomic,assign) BOOL atLeatOneCheck;
@property(nonatomic,assign) NSUInteger checkedIndex;
@property(nonatomic,readonly) NIPCheckBoxView *checkedItem;
@property(nonatomic,assign) ZBLayoutType layoutType;
@property(nonatomic,readonly) NIPLayoutBase *layoutView;

-(void)addCheckBox:(NIPCheckBoxView*)box;

@end
