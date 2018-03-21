//
//  NIPSwitchView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPStateButton.h"
#import "NIPHorizontalLayout.h"

@interface NIPStateButton()
-(void)tapAction:(UITapGestureRecognizer*)sender;
@end

@implementation NIPStateButton {
    UIImageView *_stateBackgroundView;
}

@dynamic switchOnImage;
@dynamic switchOffImage;
@dynamic text;
@dynamic switchOffBackgroundImage;
@dynamic switchonBackgroundImage;

@synthesize textLabel=_textLabel;
@synthesize imageView=_imageView;
@synthesize textColor = _textColor;
@synthesize textColorSwitchOn = _selectTextColor;
@synthesize edgeInsets=_edgeInsets;
@synthesize on=_on;
@synthesize canDeselect=_canDeselect;

-(id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {     
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                             action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
        
        self.canDeselect = YES;
        
        _stateBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_stateBackgroundView];
    }
    return self;
}


- (UILabel*)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        if (self.on&&self.textColorSwitchOn) {
            _textLabel.textColor = self.textColorSwitchOn;
        } else if (!self.on&&self.textColor) {
            _textLabel.textColor = self.textColor;
        }
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)setText:(NSString *)text {
    self.textLabel.text = text;
}

- (NSString*)text {
    return self.textLabel.text;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_textLabel&&!self.on) {
        _textLabel.textColor = textColor; 
    }
}

- (void)setTextColorSwitchOn:(UIColor *)textColor {
    _selectTextColor = textColor;
    if (_textLabel&&self.on) {
        _textLabel.textColor = textColor; 
    }
}

- (void)setSwitchOnImage:(UIImage *)switchOnImage {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.highlighted = self.on;
        [self addSubview:_imageView];
        [self bringSubviewToFront:_textLabel];
    }
    _imageView.highlightedImage = switchOnImage;
}

- (UIImage*)switchOnImage {
    return _imageView.highlightedImage;
}

- (void)setSwitchOffImage:(UIImage *)switchOffImage {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.highlighted = self.on;
        [self addSubview:_imageView];
    }
    _imageView.image = switchOffImage;
}

- (UIImage*)switchOffImage {
    return _imageView.image;
}

- (UIImage*)switchonBackgroundImage {
    return _stateBackgroundView.highlightedImage;
}

- (void)setSwitchonBackgroundImage:(UIImage *)switchonBackgroundImage {
    _stateBackgroundView.highlightedImage = switchonBackgroundImage;
}

- (UIImage*)switchOffBackgroundImage {
    return _stateBackgroundView.image;
}

- (void)setSwitchOffBackgroundImage:(UIImage *)switchOffBackgroundImage {
    _stateBackgroundView.image = switchOffBackgroundImage;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self setNeedsLayout];
}

- (void)setOn:(BOOL)on {
    if (_on!=on) {
        _on = on;
        _imageView.highlighted = self.on;
        _stateBackgroundView.highlighted = self.on;
        _textLabel.textColor = self.on?self.textColorSwitchOn:self.textColor;
    }
}

-(void)tapAction:(UITapGestureRecognizer*)sender {
    if (self.on&&!self.canDeselect) {
        return;
    }
    if (sender.state==UIGestureRecognizerStateRecognized) {
        self.on = !self.on;
        [super sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)resizeToContent {
    CGSize imageSize = self.switchOnImage.size;
    [_textLabel sizeToFit];
    CGSize textSize = _textLabel.size;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            imageSize.width+textSize.width+5, MAX(imageSize.height, textSize.height));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _stateBackgroundView.frame = self.bounds;
    [self sendSubviewToBack:_stateBackgroundView];
    
    CGFloat x = self.edgeInsets.left;
    CGFloat innerHeight = self.bounds.size.height-self.edgeInsets.top-self.edgeInsets.bottom;
    if (_imageView.image) {
        _imageView.frame = CGRectMake(x, self.edgeInsets.top,_imageView.image.size.width, _imageView.image.size.height);
        x += _imageView.width+5;
    }
    if (_textLabel) {
        [_textLabel sizeToFit];
        _textLabel.frame = CGRectMake(x, self.edgeInsets.top+(innerHeight-_textLabel.height)/2,
                                      self.bounds.size.width-x-self.edgeInsets.right, _textLabel.height);
    }
}

@end
