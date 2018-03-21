//
//  NIPSeparatorView.m
//  NSIP
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPSeparatorView.h"
#import "nip_macros.h"
#import "UIColor+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"

@implementation NIPSeparatorView


+ (CGFloat)height
{
    return 0.5f;
}

+ (NIPSeparatorView *)separatorView
{
    NIPSeparatorView *separatorView = [[NIPSeparatorView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self height])];
    separatorView.backgroundColor = [UIColor colorWithHexRGB:0xe5e5e5];
    return separatorView;
}

+ (NIPSeparatorView *)separatorOfHeight:(CGFloat)height {
    NIPSeparatorView *separatorView = [[NIPSeparatorView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    separatorView.backgroundColor = [UIColor colorWithHexRGB:0xe5e5e5];
    return separatorView;
}

+ (NIPSeparatorView *)dashSeparatorOfHeight:(CGFloat)height {
    NIPSeparatorView *separatorView = [[NIPSeparatorView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    separatorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dash_line"]];
    return separatorView;
}

+ (NIPSeparatorView *)verticalSeparatorOfHeight:(CGFloat)height {
    NIPSeparatorView *separatorView = [[NIPSeparatorView alloc] initWithFrame:CGRectMake(0, 0, 0.5,height)];
    separatorView.backgroundColor = [UIColor colorWithHexRGB:0xe5e5e5];
    return separatorView;
}

+ (NIPSeparatorView *)separatorOfHeight:(CGFloat)height horizentalInset:(CGFloat)inset {
    NIPSeparatorView *separatorView = [[NIPSeparatorView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,height)];
    separatorView.width -= 2*inset;
    separatorView.backgroundColor = [UIColor colorWithHexRGB:0xe5e5e5];
    return separatorView;
}


@end
