//
//  NIPKeyValueLabel.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPKeyValueLabel.h"
#import "nip_ui_additions.h"

@implementation NIPKeyValueLabel {
    NIPLayoutBase *_layout;
    UILabel *_keyLabel;
    UILabel *_valueLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame layoutType:ZBLayoutTypeHorizon];
}

- (id)initWithFrame:(CGRect)frame layoutType:(ZBLayoutType)layoutType {
    if (self=[super initWithFrame:frame]) {
        _layout = [NIPLayoutBase layoutOfType:layoutType];
        _layout.frame = self.bounds;
        [self addSubview:_layout];
        
        _keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        _keyLabel.backgroundColor = [UIColor clearColor];
        _keyLabel.textAlignment = NSTextAlignmentCenter;
        [_layout addSubview:_keyLabel withOpion:ZBLayoutOptionAlignmentCenter];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        _valueLabel.numberOfLines = 0;
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        [_layout addSubview:_valueLabel withOpion:ZBLayoutOptionAlignmentCenter];
    }
    return self;
}

- (void)setKeyText:(NSString *)keyText {
    _keyLabel.text = keyText;
}

- (NSString*)keyText {
    return _keyLabel.text;
}

- (void)setValueText:(NSString *)valueText {
    _valueLabel.text = valueText;
}

- (NSString*)valueText {
    return _valueLabel.text;
}

- (void)swapKeyValuePosition {
    BOOL keyFirst = YES;
    if ([_layout indexOfSubView:_keyLabel]>[_layout indexOfSubView:_valueLabel]) {
        keyFirst = NO;
    }
    [_layout removeSubView:_keyLabel];
    [_layout removeSubView:_valueLabel];
    if (keyFirst) {
        [_layout addSubview:_valueLabel withOpion:ZBLayoutOptionAlignmentCenter];
        [_layout addSubview:_keyLabel withOpion:ZBLayoutOptionAlignmentCenter];
    } else {
        [_layout addSubview:_keyLabel withOpion:ZBLayoutOptionAlignmentCenter];
        [_layout addSubview:_valueLabel withOpion:ZBLayoutOptionAlignmentCenter];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([_layout isKindOfClass:[NIPVerticalLayout class]]) {
        CGFloat labelWidth = self.bounds.size.width-_layout.contentInsets.left-_layout.contentInsets.right;
        _keyLabel.size = [_keyLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        _valueLabel.size = [_valueLabel sizeThatFits:CGSizeMake(labelWidth,CGFLOAT_MAX)];
    } else if ([_layout isKindOfClass:[NIPHorizontalLayout class]]) {
        CGFloat labelWidth = self.bounds.size.width-_layout.contentInsets.left-_layout.contentInsets.right-_layout.defaultSpacing;
        _keyLabel.size = [_keyLabel sizeThatFits:CGSizeMake(self.staticKeyPartWidth, CGFLOAT_MAX)];
        _valueLabel.size = [_valueLabel sizeThatFits:CGSizeMake(labelWidth-self.staticKeyPartWidth,CGFLOAT_MAX)];
    }
    _layout.frame = self.bounds;
    [_layout setNeedsLayout];
}

@end
