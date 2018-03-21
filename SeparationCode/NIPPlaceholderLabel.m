//
//  NIPPlaceholderLabel.m
//  NSIP
//
//  Created by 赵松 on 16/12/13.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPPlaceholderLabel.h"
#import "UIColor+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"

@implementation NIPPlaceholderLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.text.length==0) {
        [[UIColor colorWithHexRGB:0xc7c7cd] setFill];
        [self.placeholder drawInRect:CGRectInset(self.bounds, 0, (self.height-self.font.lineHeight)/2)
                      withAttributes:@{NSFontAttributeName: self.font}];
    }
    
}

@end
