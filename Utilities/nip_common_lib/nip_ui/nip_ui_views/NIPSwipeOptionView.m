//
//  NIPSwipeOptionView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPSwipeOptionView.h"
#import "nip_ui_additions.h"

@implementation NIPSwipeOptionView {
    ZBSwipeOptionRevealDirection _currentDirection;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [panGestureRecognizer setDelegate:(id<UIGestureRecognizerDelegate>)self];
        [self addGestureRecognizer:panGestureRecognizer];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self addGestureRecognizer:tapGesture];
        
        self.revealDirection = ZBSwipeOptionRevealDirectionBoth;
        self.animationType = ZBSwipeOptionAnimationTypeBounce;
        self.animationDuration = 0.2f;
        self.shouldAnimateCellReset = YES;
        self.panElasticity = YES;
        self.enableSwipGesture = YES;
        self.panElasticityStartingPoint = 0;
        
        _currentDirection = ZBSwipeOptionRevealDirectionNone;
    }
    return self;
}

- (void)setLeftOptionView:(UIView *)leftOptionView {
    [self.leftOptionView removeFromSuperview];
    
    leftOptionView.frame = CGRectMake(0, 0, leftOptionView.frame.size.width
                                      , leftOptionView.frame.size.height);
    leftOptionView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:leftOptionView];
    [self bringSubviewToFront:self.contentView];
    
    _leftOptionView = leftOptionView;
}

- (void)setRightOptionView:(UIView *)rightOptionView {
    [self.rightOptionView removeFromSuperview];
    
    rightOptionView.frame = CGRectMake(self.bounds.size.width-rightOptionView.frame.size.width, 0, rightOptionView.frame.size.width
                                      , rightOptionView.frame.size.height);
    rightOptionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:rightOptionView];
    [self bringSubviewToFront:self.contentView];
    
    _rightOptionView = rightOptionView;
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    
    contentView.frame = self.bounds;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:contentView];
    [self bringSubviewToFront:self.contentView];
    
    _contentView = contentView;
}

#pragma mark - Gesture recognizer delegate

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if  (!self.enableSwipGesture) {
        return NO;
    }
    // We only want to deal with the gesture of it's a pan gesture
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        && self.revealDirection != ZBSwipeOptionRevealDirectionNone) {
        CGPoint translation = [panGestureRecognizer translationInView:self];
        return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
    } else if([panGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        if (_currentDirection!=ZBSwipeOptionRevealDirectionNone) {
            return CGRectContainsPoint(self.contentView.bounds, [panGestureRecognizer locationInView:self.contentView]);
        }
        return NO;
    } else {
        return NO;
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    CGFloat panOffset = translation.x;
    if (self.panElasticity) {
        if (ABS(translation.x) > self.panElasticityStartingPoint) {
            CGFloat width = CGRectGetWidth(self.frame);
            CGFloat offset = fabs(translation.x);
            panOffset = (offset * 0.55f * width) / (offset * 0.55f + width);
            panOffset *= translation.x < 0 ? -1.0f : 1.0f;
            if (self.panElasticityStartingPoint > 0) {
                panOffset = translation.x > 0 ? panOffset + self.panElasticityStartingPoint / 2 : panOffset - self.panElasticityStartingPoint / 2;
            }
        }
    }
    CGPoint actualTranslation = CGPointMake(panOffset, translation.y);
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan && [panGestureRecognizer numberOfTouches] > 0) {
        [self animateContentViewForOffset:actualTranslation velocity:velocity];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged && [panGestureRecognizer numberOfTouches] > 0) {
        [self animateContentViewForOffset:actualTranslation velocity:velocity];
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self anchorContentViewFromPoint:actualTranslation  velocity:velocity];
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer*)tapGesture {
    [self resetContentView:YES];
}


#pragma mark - Gesture animations

-(void)animateContentViewForOffset:(CGPoint)point velocity:(CGPoint)velocity {
    CGRect frame = self.contentView.bounds;
    frame.origin.x +=point.x;
    if (_currentDirection==ZBSwipeOptionRevealDirectionLeft) {
        frame.origin.x += self.leftOptionView.frame.size.width;
        frame.origin.x = MAX(frame.origin.x, 0);
    } else if (_currentDirection==ZBSwipeOptionRevealDirectionRight) {
        frame.origin.x -= self.rightOptionView.frame.size.width;
        frame.origin.x = MIN(frame.origin.x, 0);
    } else if (self.revealDirection==ZBSwipeOptionRevealDirectionLeft) {
        frame.origin.x = MAX(frame.origin.x, 0);
    } else if (self.revealDirection==ZBSwipeOptionRevealDirectionRight) {
        frame.origin.x = MIN(frame.origin.x, 0);
    }
    self.contentView.frame = frame;
}

- (void)anchorContentViewFromPoint:(CGPoint)point velocity:(CGPoint)velocity {
    if (self.leftOptionView&&self.contentView.frame.origin.x+velocity.x>=self.leftOptionView.frame.size.width) {
        CGRect targetFrame = CGRectOffset(self.contentView.bounds, self.leftOptionView.frame.size.width, 0);
        [UIView animateWithDuration:fabs(targetFrame.origin.x-self.contentView.frame.origin.x)/200
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.contentView.frame = targetFrame;
                             _currentDirection = ZBSwipeOptionRevealDirectionLeft;
                         }
                         completion:nil
         ];
    } else  if (self.rightOptionView&&self.contentView.frame.origin.x+velocity.x<=-self.rightOptionView.frame.size.width) {
        CGRect targetFrame = CGRectOffset(self.contentView.bounds, -self.rightOptionView.frame.size.width, 0);
        [UIView animateWithDuration:fabs(targetFrame.origin.x-self.contentView.frame.origin.x)/200
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.contentView.frame = targetFrame;
                             _currentDirection = ZBSwipeOptionRevealDirectionRight;
                         }
                         completion:nil];
    } else {
        [self resetContentView:YES];
    }
}

- (void)revealOption:(ZBSwipeOptionRevealDirection)direction {
    if (direction==ZBSwipeOptionRevealDirectionRight&&self.rightOptionView) {
        [UIView animateWithDuration:fabs(self.rightOptionView.width)/200.0f
                              delay:0
                            options:0
                         animations:^{
                             self.contentView.frame = CGRectOffset(self.contentView.bounds, -self.rightOptionView.width, 0);
                         }
                         completion:^(BOOL finished) {
                             _currentDirection = ZBSwipeOptionRevealDirectionRight;
                         }
         ];
    } else if (direction==ZBSwipeOptionRevealDirectionLeft&&self.leftOptionView) {
        [UIView animateWithDuration:fabs(self.leftOptionView.width)/200.0f
                              delay:0
                            options:0
                         animations:^{
                             self.contentView.frame = CGRectOffset(self.contentView.bounds, +self.leftOptionView.width, 0);
                         }
                         completion:^(BOOL finished) {
                             _currentDirection = ZBSwipeOptionRevealDirectionLeft;
                         }
         ];
    } else if (direction==ZBSwipeOptionRevealDirectionNone) {
        [self resetContentView:YES];
    }
}

-(void)resetContentView:(BOOL)animated {
    CGPoint point = self.contentView.frame.origin;
    if (animated) {
        if (self.animationType == ZBSwipeOptionAnimationTypeBounce) {
            [UIView animateWithDuration:fabs(point.x)/400.0f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.contentView.frame = CGRectOffset(self.contentView.bounds, 0 - (point.x * 0.03), 0);
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.1
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      self.contentView.frame = CGRectOffset(self.contentView.bounds, 0 + (point.x * 0.02), 0);
                                                  }
                                                  completion:^(BOOL finished) {
                                                      [UIView animateWithDuration:0.1
                                                                            delay:0
                                                                          options:UIViewAnimationOptionCurveEaseOut
                                                                       animations:^{
                                                                           self.contentView.frame = self.contentView.bounds;
                                                                       }
                                                                       completion:nil
                                                       ];
                                                  }
                                  ];
                             }
             ];
        } else {
            [UIView animateWithDuration:fabs(point.x)/200.0f
                                  delay:0
                                options:(UIViewAnimationOptions)self.animationType
                             animations:^{
                                 self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
                             }
                             completion:nil
             ];
        }
    } else {
        self.contentView.frame = self.bounds;
    }

    _currentDirection = ZBSwipeOptionRevealDirectionNone;
}


@end
