//
//  NIPLabelView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPLabelView.h"

@implementation NIPLabelView

@synthesize label = _label;
@synthesize edgeInsets=_edgeInsets;
@dynamic backgroundImage;
@dynamic text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }
    return self;
}

- (void)setText:(NSString *)text {
        _label.text = text;
}

- (NSString*)text {
    return _label.text;
}

- (void)resizeHeightOnContent {
    CGFloat textWidth = self.bounds.size.width-self.edgeInsets.left-self.edgeInsets.right;
    CGSize maxLabelSize = CGSizeMake(textWidth,CGFLOAT_MAX);
    CGSize textSize = [_label.text boundingRectWithSize:maxLabelSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_label.font} context:nil].size;
    if (textSize.height>0.0f) {
        self.height = textSize.height+self.edgeInsets.bottom+self.edgeInsets.top;
    } else {
        self.height = 0;
    }
    [self setNeedsLayout];
}

- (void)resizeToContent {
    CGSize textSize = [_label sizeThatFits:CGSizeMake(CGFLOAT_MAX, self.height)];
    self.size = CGSizeMake(textSize.width<=0.0f?0.0f:(self.edgeInsets.left+self.edgeInsets.right+textSize.width),
                           textSize.height<=0.0f?0.0f:self.edgeInsets.top+self.edgeInsets.bottom+textSize.height);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect labelFrame =  CGRectMake(self.edgeInsets.left, self.edgeInsets.top,
               self.bounds.size.width-self.edgeInsets.left-self.edgeInsets.right,
               self.bounds.size.height-self.edgeInsets.top-self.edgeInsets.bottom);
    if (_label) {
        _label.frame = labelFrame;
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self setNeedsLayout];
}

@end
