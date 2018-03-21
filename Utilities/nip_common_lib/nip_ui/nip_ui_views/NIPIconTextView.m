//
//  NIPIconTextView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPIconTextView.h"


@implementation NIPIconTextView

@dynamic icon;
@dynamic text;
@dynamic textColor;
@dynamic font;
@dynamic alignment;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_iconView];
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLabel];
        self.iconTextSpace = 3;
    }
    return self;
}


- (void)setIcon:(UIImage*)image {
    _iconView.image = image;
    [self setNeedsLayout];
}

- (UIImage*)icon {
    return _iconView.image;
}

- (void)setText:(id)text {
    if ([text isKindOfClass:[NSAttributedString class]]) {
        _textLabel.attributedText = (NSAttributedString*)text;
    } else {
        _textLabel.text = text;
    }
    [self setNeedsLayout];
}

- (id)text {
    if (_textLabel.attributedText) {
        return _textLabel.attributedText;
    }
    return _textLabel.text;
}

- (void)setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
}

- (UIColor*)textColor {
    return _textLabel.textColor;
}

- (void)setFont:(UIFont *)textFont {
    _textLabel.font = textFont;
}

- (UIFont*)font {
    return _textLabel.font;
}

- (void)setAlignment:(NSTextAlignment)alignment {
    _textLabel.textAlignment = alignment;
}

- (NSTextAlignment)alignment {
    return _textLabel.textAlignment;
}

-(void)resizeToContent {
    CGSize iconSize = _iconView.image.size;    
    CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    if (self.verticalLayout) {
        if (iconSize.height>0) {
            iconSize.height += self.iconTextSpace;
        }
        CGRect frame = self.frame;
        frame.size.width = self.edgeInserts.left+self.edgeInserts.right+MAX(iconSize.width,textSize.width);
        frame.size.height = self.edgeInserts.top +self.edgeInserts.bottom+ +iconSize.height+textSize.height;
        self.frame = frame;
    } else {
        if (iconSize.width>0) {
            iconSize.width += self.iconTextSpace;
        }
        CGRect frame = self.frame;
        frame.size.width = self.edgeInserts.left+self.edgeInserts.right+iconSize.width+textSize.width;
        frame.size.height = self.edgeInserts.top +self.edgeInserts.bottom+ MAX(iconSize.height, textSize.height);
        self.frame = frame;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    UIImage *image = _iconView.image;
    CGSize iconSize = image.size;
    CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat space = self.iconTextSpace;
    if (iconSize.width==0) {
        space = 0;
    }  
    UIView *firstView = _iconView;
    UIView *secondeView = _textLabel;
    if (self.textFirst) {
        firstView = _textLabel;
        secondeView = _iconView;
    }
    if (self.verticalLayout) {
        _textLabel.size = textSize;
        _iconView.size = iconSize;
        CGFloat allheight = iconSize.height+space+textSize.height;
        CGFloat y = self.edgeInserts.top+(self.bounds.size.height-allheight-self.edgeInserts.top-self.edgeInserts.bottom)/2;
        CGFloat x =  self.edgeInserts.left +(self.bounds.size.width-self.edgeInserts.left-self.edgeInserts.right)/2;
        firstView.center = CGPointMake(x, y+firstView.height/2);
        x =  self.edgeInserts.left +(self.bounds.size.width-self.edgeInserts.left-self.edgeInserts.right)/2;
        secondeView.center = CGPointMake(x, firstView.bottom+space+secondeView.height/2);
    } else {
        CGFloat allWidth = iconSize.width+space+textSize.width;
        CGFloat diff = self.bounds.size.width-self.edgeInserts.left-self.edgeInserts.right-allWidth;
        if (diff<0) {
            textSize.width+=diff;
            allWidth +=diff;
        }
        _textLabel.size = textSize;
        _iconView.size = iconSize;
        
        CGFloat left = 0;
        if (self.alignment==NSTextAlignmentLeft) {
            left = self.edgeInserts.left;
        } else if (self.alignment==NSTextAlignmentCenter) {
            left = (self.bounds.size.width-allWidth)/2;
        } else if (self.alignment==NSTextAlignmentRight) {
            left = self.bounds.size.width-allWidth-self.edgeInserts.right;
        }
        CGFloat y = self.edgeInserts.top+(self.bounds.size.height-self.edgeInserts.top-self.edgeInserts.bottom)/2;
        firstView.center = CGPointMake(left+firstView.width/2, y);
        secondeView.center = CGPointMake(firstView.right+space+secondeView.width/2,y);
    }
}

@end
