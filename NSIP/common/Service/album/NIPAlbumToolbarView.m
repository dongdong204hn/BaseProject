//
//  NIPAlbumToolbarView.m
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPAlbumToolbarView.h"
#import "NIPNumblerLabel.h"
#import "NIPUIFactory.h"
#import "UIColor+NIPBasicAdditions.h"


@interface NIPAlbumToolbarView ()

@property (nonatomic, strong) UIButton *previewBtn;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) NIPNumblerLabel *numberLabel;

@end

@implementation NIPAlbumToolbarView


- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViews];
        [self addConstraints];
    }
    return self;
}

- (void)initViews {
    [self addSubview:self.previewBtn];
    [self addSubview:self.doneBtn];
    [self addSubview:self.numberLabel];
}

- (void)addConstraints {
    [self.previewBtn autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.previewBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.previewBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.previewBtn autoSetDimension:ALDimensionWidth toSize:60];
    
    [self.doneBtn autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.doneBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.doneBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [self.doneBtn autoSetDimension:ALDimensionWidth toSize:40];
    
    [self.numberLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.numberLabel autoSetDimensionsToSize:CGSizeMake(16, 16)];
    [self.numberLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.doneBtn];
}


- (void)previewBtnPressed:(id)sender {
    if (self.previewBlock) {
        self.previewBlock();
    }
}

- (void)doneBtnPressed:(id)sender {
    if (self.doneBlock) {
        self.doneBlock();
    }
}

- (void)hidePreviewBtn {
    self.previewBtn.hidden = YES;
}

- (void)setNumber:(NSInteger)number animated:(BOOL)animated {
    if (number > 0) {
        self.previewBtn.enabled = YES;
        self.doneBtn.enabled = YES;
        self.numberLabel.hidden = NO;
        [self.numberLabel setNumber:number animated:animated];
    } else {
        self.previewBtn.enabled = NO;
        self.doneBtn.enabled = NO;
        self.numberLabel.hidden = YES;
    }
}

- (UIButton *)previewBtn {
    if (!_previewBtn) {
        _previewBtn = [NIPUIFactory buttonWithTitle:@"预览"
                                           fontSize:15
                                             target:self
                                           selector:@selector(previewBtnPressed:)];
       [_previewBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _previewBtn.enabled = NO;
    }
    return _previewBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [NIPUIFactory buttonWithTitle:@"完成"
                                        fontSize:15
                                          target:self
                                        selector:@selector(doneBtnPressed:)];
        [_doneBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithIntegerR:0 g:255 b:0 a:0.3] forState:UIControlStateDisabled];
        _doneBtn.enabled = NO;
    }
    return _doneBtn;
}

- (NIPNumblerLabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [NIPNumblerLabel numberLableWithTitleColor:[UIColor whiteColor]
                                               andBackgroundColor:[UIColor greenColor]];
        _numberLabel.hidden = YES;
    }
    return _numberLabel;
}



@end
