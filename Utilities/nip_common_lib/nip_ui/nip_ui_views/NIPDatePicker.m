//
//  NIPDatePicker.m
//  trainTicket
//
//  Created by 赵松 on 15/5/22.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "NIPDatePicker.h"
#import "NIPUIFactory.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "NIPSeparatorView.h"
#import "NSDateFormatter+NIPBasicAdditions.h"
#import "nip_macros.h"
#import "UIView+NIPBasicAdditions.h"

@interface NIPDatePicker ()

@property (nonatomic, strong) UIDatePicker *picker;

@end

@implementation NIPDatePicker

+ (instancetype)datePickerWithTitle:(NSString *)title {
    return [[NIPDatePicker alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 264,SCREEN_WIDTH, 264)];
        content.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        if ([toolbar respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
            [toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        
        toolbar.translucent = YES;
        [content insertSubview:toolbar atIndex:0];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
        headerView.backgroundColor = [UIColor clearColor];
        [content addSubview:headerView];
        
        UIButton *button = [NIPUIFactory buttonWithTitle:@"取消" fontSize:16.f target:self selector:@selector(cancelButtonPressed:)];
        button.frame = CGRectMake(0, 0, 60, 47.5);
        button.tag = 0;
        if ([UIDevice systemMainVersion] >= 7) {
            [button setTitleColor:[NIPUIFactory blueTextColor] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }

        [headerView addSubview:button];
        
        button = [NIPUIFactory buttonWithTitle:@"确定" fontSize:16.f target:self selector:@selector(okButtonPressed:)];
        button.frame = CGRectMake(self.width - 60, 0, 60, 47.5);
        button.tag = 1;
        if ([UIDevice systemMainVersion] >= 7) {
            [button setTitleColor:[NIPUIFactory blueTextColor] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [headerView addSubview:button];
        
        UILabel *titleLabel = [NIPUIFactory labelWithText:title fontSize:18.0f andTextColor:[UIColor blackColor]];
        titleLabel.center = CGPointMake(self.width/2, 24);
        [headerView addSubview:titleLabel];
        
        NIPSeparatorView *sep = [NIPSeparatorView separatorView];
        [content addSubview:sep];
        sep.topLeft = CGPointMake(0.f, 47.5f);
        
        self.picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 48, SCREEN_WIDTH, 216)];
        self.picker.datePickerMode = UIDatePickerModeDate;
        self.picker.backgroundColor = [UIColor whiteColor];
        [content addSubview:self.picker];
        
        self.contentView = content;
        self.animationType = ZBAlertAnmiationSheet;
    }
    return self;
}

- (void)willShow {
    if (!self.date) {
        self.date = [[NSDateFormatter defaultDateFormatter] dateFromString:@"1980-01-01"];
    }
    self.picker.date = _date;
}

- (void)okButtonPressed:(UIButton*)sender {
    self.date = self.picker.date;
    [self dismissWithButtonIndex:sender.tag];
}
-(void)cancelButtonPressed:(UIButton *)sender
{
    [self dismissWithButtonIndex:sender.tag];
}

@end
