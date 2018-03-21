//
//  NIPNumblerLabel.m
//  NSIP
//
//  Created by Eric on 2016/12/19.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPNumblerLabel.h"
#import "NIPUIFactory.h"


@interface NIPNumblerLabel ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation NIPNumblerLabel

+ (NIPNumblerLabel *)numberLableWithTitleColor:(UIColor *)titleColor andBackgroundColor:(UIColor *)backgroundColor {
    NIPNumblerLabel *nuberLabelView = [[NIPNumblerLabel alloc] initWithFrame:CGRectZero];
    nuberLabelView.numberLabel.textColor = titleColor;
    nuberLabelView.backgroundView.layer.backgroundColor = backgroundColor.CGColor;
    return nuberLabelView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initViews];
        [self addConstraints];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViews];
        [self addConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)initViews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.numberLabel];
}

- (void)addConstraints {
    [_backgroundView autoPinEdgesToSuperviewEdges];
    [_numberLabel autoPinEdgesToSuperviewEdges];
}

- (void)setNumber:(NSInteger)number animated:(BOOL)animated {
    NSString *numberStr = [@(number) stringValue];
    if ([numberStr isEqualToString:self.numberLabel.text]) {
        return;
    }
    self.numberLabel.text = numberStr;
    if (animated) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values  = @[[NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:0.90],
                              [NSNumber numberWithFloat:1.0]];
        animation.fillMode = kCAFillModeBoth;
        animation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = 0.3;
        [self.backgroundView.layer addAnimation:animation forKey:@"shake"];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.numberLabel.textColor = titleColor;
}

- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor {
    self.backgroundView.layer.backgroundColor = backgroundViewColor.CGColor;
}


- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.layer.cornerRadius = _backgroundView.bounds.size.width/2;
        _backgroundView.layer.backgroundColor = [UIColor greenColor].CGColor;
    }
    return _backgroundView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [NIPUIFactory labelWithText:@"" fontSize:13 andTextColor:[UIColor whiteColor]];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numberLabel;
}


@end
