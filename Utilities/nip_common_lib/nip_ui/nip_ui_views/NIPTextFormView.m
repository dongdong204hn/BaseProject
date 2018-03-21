//
//  NIPTextFormView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPTextFormView.h"

@implementation NIPTextFormView

- (id)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.columnCount = 2;
    }
    return self;
}

- (void)setTextArray:(NSArray*)textArray {
    [self removeAllSubViews];
    
    BOOL colum1 = YES;
    for (NSString *text in textArray) {
        UIFont *font = colum1?self.colum1Font:self.colum2Font;
        UIColor *textColor = colum1?self.colum1Color:self.colum2Color;
        CGFloat width = colum1?self.colum1Width:self.colum2Width;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, font.pointSize+4)];
        label.text = text;
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.textColor = textColor;
        [self addSubview:label];
        
        colum1 = !colum1;
    }
}

@end
