//
//  NIProgressView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIProgressView.h"

@implementation NIProgressView
@synthesize progress=_progress;
@synthesize progressColor=_progressColor;
@synthesize progressEndColor=_progressEndColor;
@synthesize progressBackColor=_progressBackColor;
@synthesize progressBorderColor=_progressBorderColor;

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 12;
    self = [super initWithFrame:frame];
    if (self) {
        _progressColor =[UIColor colorWithRed:0xe7/255.0 green:0x6b/255.0 blue:0x21/255.0 alpha:1.0];
        _progressEndColor =[UIColor colorWithRed:0xbd/255.0 green:0x27/255.0 blue:0x03/255.0 alpha:1.0];
        _progressBackColor =[UIColor colorWithRed:0xc2/255.0 green:0x8f/255.0 blue:0x22/255.0 alpha:1.0];
        self.opaque = NO;
    }
    return self;
}


-(void)setProgress:(float)progress {
    if (_progress!=progress) {
        _progress=progress;
        [self setNeedsDisplay];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_progressBackColor setFill];
    CGPathRef barPath = CGPathCreateRoundrect(self.bounds,self.bounds.size.height/2);
    CGContextAddPath(context, barPath);
    CGContextClip(context);
    CGPathRelease(barPath);
    
    CGFloat backLocations[] = { 0.0,1.0};
    CGFloat backColors[]={0xA4/255.0,0x6A/255.0,0x1A/255.0,1.0
        ,0xce/255.0,0x92/255.0,0x26/255.0,1.0};
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef backGradient = CGGradientCreateWithColorComponents(colorspace, backColors,
                                                                 backLocations, 2);
	
	CGPoint startPoint = self.bounds.origin;
	CGPoint endPoint = CGPointMake(startPoint.x,startPoint.y+self.bounds.size.height);
	CGContextDrawLinearGradient(context, backGradient, startPoint, endPoint, 0);
    CGGradientRelease(backGradient);
    
    CGFloat progressLength = (self.bounds.size.width-2)*self.progress;
    CGRect progressRect = CGRectMake(self.bounds.origin.x+1, self.bounds.origin.y+1, progressLength, self.bounds.size.height-2);
    CGPathRef progressPath = CGPathCreateRoundrect(progressRect,progressRect.size.height/2);
    CGContextAddPath(context,progressPath);
    CGContextClip(context);
    CGPathRelease(progressPath);
    
    CGFloat progresslocations[3] = { 0.0, 0.7, 1.0 };
    if (48.0>progressLength) {
        progresslocations[1] = 0.0;
    } else {
        progresslocations[1] = 5.0/progressLength;
    }
    CGFloat progressColors[]={0xe7/255.0,0x6b/255.0,0x21/255.0,1.0
                        ,0xe7/255.0,0x6b/255.0,0x21/255.0,1.0
                        ,0xbd/255.0,0x27/255.0,0x03/255.0,1.0};
	CGGradientRef progressGradient = CGGradientCreateWithColorComponents(colorspace, progressColors,
                                                                  progresslocations, 3);
	
	startPoint = progressRect.origin;
	endPoint = CGPointMake(startPoint.x+progressRect.size.width,startPoint.y);
	CGContextDrawLinearGradient(context, progressGradient, startPoint, endPoint, 0);
    CGGradientRelease(progressGradient);
    
    CGColorSpaceRelease(colorspace);
}


@end
