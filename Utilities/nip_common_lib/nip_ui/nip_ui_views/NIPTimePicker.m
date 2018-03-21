//
//  NIPTimePicker.m
//  trainTicket
//
//  Created by 赵松 on 15/5/22.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "NIPTimePicker.h"
#import "NIPSeparatorView.h"
#import "NIPUIFactory.h"
#import "nip_macros.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"

@interface NIPTimePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *picker;

@end

@implementation NIPTimePicker

+ (instancetype)timePickerWithTitle:(NSString *)title {
    return [[NIPTimePicker alloc] initWithTitle:title];
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
        [button setTitleColor:[NIPUIFactory blueTextColor] forState:UIControlStateNormal];
        [headerView addSubview:button];
        
        button = [NIPUIFactory buttonWithTitle:@"确定" fontSize:16.f target:self selector:@selector(okButtonPressed:)];
        button.frame = CGRectMake(self.width - 60, 0, 60, 47.5);
        button.tag = 1;
        [button setTitleColor:[NIPUIFactory blueTextColor] forState:UIControlStateNormal];
        [headerView addSubview:button];
        
        UILabel *titleLabel = [NIPUIFactory labelWithText:title fontSize:18.0f andTextColor:[UIColor blackColor]];
        titleLabel.center = CGPointMake(self.width/2, 24);
        [headerView addSubview:titleLabel];
        
        NIPSeparatorView *sep = [NIPSeparatorView separatorView];
        [content addSubview:sep];
        sep.topLeft = CGPointMake(0.f, 47.5f);
        
        self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 48, SCREEN_WIDTH, 216)];
        self.picker.dataSource = self;
        self.picker.delegate = self;
        self.picker.backgroundColor = [UIColor clearColor];
        self.picker.showsSelectionIndicator = YES;
        [content addSubview:self.picker];
        
        if ([UIDevice systemMainVersion]>=7) {
            UILabel *label = [NIPUIFactory labelWithText:@"到" andFontSize:16.0f];
            label.center = _picker.center;
            [content addSubview:label];
        }
        
        self.contentView = content;
        self.animationType = ZBAlertAnmiationSheet;
        
        [_picker selectRow:24 inComponent:1 animated:NO];
    }
    return self;
}

- (void)dealloc {
    _picker.delegate = nil;
    _picker.dataSource = nil;
}

- (void)willShow {
    if (self.dateStart.length>0) {
        NSInteger startIndex = [self.dateStart integerValue];
        [_picker selectRow:startIndex inComponent:0 animated:NO];
    }
    if (self.dateEnd.length>0) {
        NSInteger endIndex = [self.dateEnd integerValue];
        [_picker selectRow:endIndex inComponent:1 animated:NO];
    }
}

- (void)okButtonPressed:(UIButton*)sender {
    self.dateStart = [self pickerView:_picker titleForRow:[_picker selectedRowInComponent:0] forComponent:0];
    NSUInteger endIndex = MAX([_picker selectedRowInComponent:1], [_picker selectedRowInComponent:0]);
    self.dateEnd = [self pickerView:_picker titleForRow:endIndex forComponent:1];
    [self dismissWithButtonIndex:sender.tag];
}

-(void)cancelButtonPressed:(UIButton *)sender
{
    [self dismissWithButtonIndex:sender.tag];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if ([UIDevice systemMainVersion]>=7) {
        return 160;
    } else {
        return 140;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView selectedRowInComponent:1]<[pickerView selectedRowInComponent:0]) {
        [pickerView selectRow:[pickerView selectedRowInComponent:0] inComponent:1 animated:NO];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 25;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%02ld:00",(long)row];
}

@end
