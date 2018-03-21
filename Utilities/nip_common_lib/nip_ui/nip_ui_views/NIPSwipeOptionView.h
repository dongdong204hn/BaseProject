//
//  NIPSwipeOptionView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZBSwipeOptionRevealDirection) {
    ZBSwipeOptionRevealDirectionNone = -1, // disables panning
    ZBSwipeOptionRevealDirectionBoth = 0,
    ZBSwipeOptionRevealDirectionRight = 1,
    ZBSwipeOptionRevealDirectionLeft = 2,
};

typedef NS_ENUM(NSUInteger, ZBSwipeOptionAnimationType) {
    ZBSwipeOptionAnimationTypeEaseInOut            = 0 << 16,
    ZBSwipeOptionAnimationTypeEaseIn               = 1 << 16,
    ZBSwipeOptionAnimationTypeEaseOut              = 2 << 16,
    ZBSwipeOptionAnimationTypeEaseLinear           = 3 << 16,
    ZBSwipeOptionAnimationTypeBounce               = 4 << 16, // default
};

/**
 *  一个支持侧滑的控件，可以用在UITableViewCell里面替代默认的侧滑操作，以支持更多的功能
 */
@interface NIPSwipeOptionView : UIView
@property(nonatomic) UIView *contentView;
@property(nonatomic) UIView *rightOptionView;
@property(nonatomic) UIView *leftOptionView;

@property (nonatomic, readwrite) ZBSwipeOptionRevealDirection revealDirection;
@property (nonatomic, readonly) ZBSwipeOptionRevealDirection currentDirection;
@property (nonatomic, readwrite) ZBSwipeOptionAnimationType animationType;
@property (nonatomic, readwrite) float animationDuration;
@property (nonatomic, readwrite) BOOL shouldAnimateCellReset;
@property (nonatomic, readwrite) BOOL panElasticity;
@property (nonatomic, readwrite) CGFloat panElasticityStartingPoint;
@property (nonatomic) BOOL enableSwipGesture;

- (void)resetContentView:(BOOL)animated;
- (void)revealOption:(ZBSwipeOptionRevealDirection)direction;
@end
