//
//  NIPTextActivityIndicator.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NIPTextActivityIndicator.h"

#define ACTIVEITY_SIZE 30

@interface NIPTextActivityIndicator()
-(void)startAnimating;
@end

@implementation NIPTextActivityIndicator

@synthesize label=_label;
@dynamic backgroundImage;

-(id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style 
                               text:(NSString*)text {
    if (self=[super initWithFrame:CGRectZero]) {       
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        [self addSubview:_indicator];
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor =[UIColor clearColor];
        _label.text = text;
        _label.textColor =[UIColor whiteColor];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        
        self.layer.cornerRadius = 5;
        
        [self resizeToContent];
        
        self.hidden = YES;
    }
    return self;
}


-(void)resizeToContent {
    CGSize maxLabelSize = CGSizeMake(200,400);
    CGSize textSize = [_label.text boundingRectWithSize:maxLabelSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_label.font} context:nil].size;
    CGRect frame = CGRectMake(0, 0, 10+ACTIVEITY_SIZE+3+textSize.width,10+MAX(ACTIVEITY_SIZE, textSize.height));

    self.frame = frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _indicator.frame = CGRectMake(5,
                                  (self.bounds.size.height-ACTIVEITY_SIZE)/2,
                                  ACTIVEITY_SIZE,
                                  ACTIVEITY_SIZE),
    [_label sizeToFit];
    _label.frame = CGRectMake(5+ACTIVEITY_SIZE+3,
                              (self.bounds.size.height-_label.height)/2 ,
                              _label.width,
                              _label.height);
}

-(void)show {
    if (self.delayMode) {
        [self performSelector:@selector(showDelay) withObject:nil afterDelay:1.0];
    } else {
        [self startAnimating];
    }
}

- (void)showDelay {
    if ([self superview]) {
        [self startAnimating];
    }
}

-(void)startAnimating {
    if (_animating) {
        return;
    }
    _animating = YES;
    self.hidden = NO;
    [_indicator startAnimating];
}
-(void)stopAnimating {
    if (!_animating) {
        return;
    }
    self.hidden = YES;
    [_indicator stopAnimating];    
}

@end
