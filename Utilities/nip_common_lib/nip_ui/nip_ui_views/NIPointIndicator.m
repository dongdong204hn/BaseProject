//
//  NIPointIndicator.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPointIndicator.h"

@implementation NIPointIndicator {
    UIImage *_pointImage;
    UIImage *_pointBackImage;
}

- (id)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        self.pointSpace = 5.0;
        self.opaque = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setPointCount:(NSInteger)pointCount {
    if  (_pointCount != pointCount) {
        _pointCount = pointCount;
        [self setNeedsDisplay];
    }    
}

- (void)setProgress:(CGFloat)progress {
    if  (_progress != progress) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setPointSpace:(CGFloat)pointSpace {
    if  (_pointSpace != pointSpace) {
        _pointSpace = pointSpace;
        [self setNeedsDisplay];
    }
}

- (void)setUserInteractionEnabled:(BOOL)enable {
    if (self.userInteractionEnabled==enable) {
        return;
    }
    [super setUserInteractionEnabled:enable];
    if (enable) {
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
    } else {
        for (UIGestureRecognizer *guesture in [self gestureRecognizers]) {
            [self removeGestureRecognizer:guesture];
        } 
    }
}

-(void)setPointImage:(UIImage*)image andBackImage:(UIImage*)backImage {
    _pointImage = image;
    _pointBackImage = backImage;
}

-(void)fillRoundRect:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius
{
	CGPoint leftTop = rect.origin;
	CGPoint rightTop = CGPointMake(leftTop.x+rect.size.width,leftTop.y);
	CGPoint rightBottom = CGPointMake(rightTop.x, rightTop.y+rect.size.height);
	CGPoint leftBottom = CGPointMake(leftTop.x, leftTop.y+rect.size.height);
	
	CGContextMoveToPoint(context, leftTop.x, leftTop.y+radius);
	CGContextAddArcToPoint(context, leftTop.x, leftTop.y, leftTop.x+radius, leftTop.y, radius);
	CGContextAddArcToPoint(context, rightTop.x, rightTop.y, rightTop.x, rightTop.y+radius,radius);
	CGContextAddArcToPoint(context, rightBottom.x, rightBottom.y, rightBottom.x-radius, rightBottom.y, radius);
	CGContextAddArcToPoint(context, leftBottom.x,leftBottom.y,leftBottom.x,leftBottom.y-radius,radius);
	CGContextClosePath(context);
	
	CGContextFillPath(context);
}

- (CGSize)getDrawPointSize {
    CGFloat maxPointheight = self.bounds.size.height;
    CGFloat maxPointWidth = (self.bounds.size.width - (self.pointCount-1)*_pointSpace)/self.pointCount;
    return CGSizeMake(MIN(maxPointheight, maxPointWidth), MIN(maxPointheight, maxPointWidth));
}


-(void)drawPoints:(CGRect)rect {
    rect = self.bounds;
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *darkColor = [UIColor colorWithRed:59/255.0f green:56/255.0f blue:50/255.0f alpha:1.0f];
    
	CGSize pointSize = [self getDrawPointSize];
	CGPoint initPoint = CGPointMake(0, (rect.size.height-pointSize.height)/2);
	
	for (int i=0; i<self.pointCount; i++) {
		CGRect smallRect = CGRectMake(initPoint.x, initPoint.y, pointSize.width, pointSize.height);
        NSInteger intProgresss = self.progress;
		if (i==intProgresss) {
            [[UIColor whiteColor] setFill];
            CGContextFillEllipseInRect(context,smallRect);
		} else {
            [darkColor setFill];
            CGContextFillEllipseInRect(context,smallRect);
        }
		initPoint.x += pointSize.width+_pointSpace;
	}	
}

-(void)drawMixImage:(UIImage*)image1 andImage:(UIImage*)image2 inRect:(CGRect)rect withPortion:(CGFloat)portion {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (portion>1.0) {
        portion=1.0;
    }
    CGContextSaveGState(context);
    CGRect leftRect = rect;
    leftRect.size.width *= portion;
    CGContextClipToRect(context, leftRect);
    [image1 drawInRect:rect];
    CGContextRestoreGState(context);  
    
    CGContextSaveGState(context);
    CGRect rightRect = rect;
    rightRect.size.width *= (1.0-portion);
    rightRect.origin.x = leftRect.origin.x+leftRect.size.width;
    CGContextClipToRect(context, rightRect);
    [image2 drawInRect:rect];
    CGContextRestoreGState(context); 
}

- (CGSize)getDrawImageSize {
    CGRect rect = self.bounds;
    CGSize pointSize = _pointImage.size;
    if (pointSize.height>rect.size.height) {
        pointSize = CGSizeMake(pointSize.width*rect.size.height/pointSize.height, rect.size.height);
    }
    if (pointSize.width*self.pointCount>rect.size.width) {
        pointSize = CGSizeMake(rect.size.width/self.pointCount,pointSize.height*rect.size.width/(self.pointCount*pointSize.height));
    }
    return pointSize;
}

-(void)drawPointImages:(CGRect)rect {
    rect = self.bounds;

	CGSize pointSize = [self getDrawImageSize];

    CGFloat space = self.pointCount==0?0:(rect.size.width-pointSize.width*self.pointCount)/self.pointCount;
    CGFloat yOffset =  (rect.size.height-pointSize.height)/2;
    CGFloat xPos = 0.0f;
    for (int i=0; i<self.pointCount; i++) {
        NSInteger intProgresss = self.progress;
        if (i<intProgresss) {
            [_pointImage drawInRect:CGRectMake(xPos, yOffset, pointSize.width, pointSize.height)];
        } else if(i==intProgresss&&self.progress-intProgresss>0.1) {
            [self drawMixImage:_pointImage andImage:_pointBackImage 
                        inRect:CGRectMake(xPos, yOffset, pointSize.width,pointSize.height)
                   withPortion:self.progress-intProgresss];
        }
        else {
            [_pointBackImage drawInRect:CGRectMake(xPos, yOffset, pointSize.width, pointSize.height)];    
        }
        xPos += (space+pointSize.width);
	}
}

-(void)tapped:(UITapGestureRecognizer*)tap {
    if (tap.state==UIGestureRecognizerStateRecognized) {
        CGPoint point = [tap locationInView:self];
        CGRect rect = self.bounds;
        CGSize pointSize = 	[self getDrawImageSize];
        CGFloat space = self.pointCount==0?0:(rect.size.width-pointSize.width*self.pointCount)/self.pointCount;
        CGFloat yOffset =  (rect.size.height-pointSize.height)/2;
        CGFloat xPos = 0.0f;
        for (int i=0; i<self.pointCount; i++) {
            CGRect pointRect = CGRectMake(xPos, yOffset, pointSize.width, pointSize.height);
            if (CGRectContainsPoint(pointRect, point)) {
                self.progress = i+1;
                break;
            }
            xPos += (space+pointSize.width);
        }
    }
}

-(void)drawRect:(CGRect)rect {
    if (_pointImage&&_pointBackImage) {
        [self drawPointImages:rect];
    } else {
        [self drawPoints:rect];
    }
}
@end

