//
//  UIView+NIPBasicAdditions.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - FindFirstResponder
/**
 *  UIView NTUIAdditions_FindFirstResponder
 */
@interface UIView(NIPAdditions_FindFirstResponder)

- (UIView*)findFirstResponder;
- (UIViewController*)parentViewController;

@end


#pragma mark - Hierarchy
/**
 *  UIView NTUIAdditions_HierarchyAddition
 */
@interface UIView (NIPAdditions_HierarchyAddition)

-(NSUInteger)getSubviewIndex;

-(void)bringToFront;
-(void)sentToBack;

-(void)bringOneLevelUp;
-(void)sendOneLevelDown;

-(BOOL)isInFront;
-(BOOL)isAtBack;

-(void)swapDepthsWithView:(UIView*)swapView;

@end


#pragma mark - Transform
/**
 *  UIView NTUIAdditions_TransformAddition
 */
@interface UIView (NIPAdditions_TransformAddition)
- (void)flipX;
- (void)flipY;
- (void)cancelFlip;

/**
 *  设置view的锚点，用于旋转等。注：避免发生偏移。
 *
 *  @param anchorPoint <#anchorPoint description#>
 */
- (void)setAnchorPoint:(CGPoint)anchorPoint;

@end


#pragma mark - Geometry
/**
 *  UIView NTUIAdditions_GeometryAddition
 */
@interface UIView (NIPAdditions_GeometryAddition)

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;


@property(nonatomic) CGPoint topLeft;
@property(nonatomic) CGPoint topRight;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

/**
 *  各种对齐方式
 */
- (void)centerVertical;
- (void)centerHorizontal;
- (void)makeCenter;

//! 视图相对屏幕的位置
- (CGRect)relativeFrameToScreen;

/**
 *  寻找符合Class类型的父view或者子view
 */
- (UIView *)superviewWhichIsInstanceOfClass:(Class)class;
- (UIView *)subviewWhichIsInstanceOfClass:(Class)class enumDirection:(NSEnumerationOptions)enumDirection;
- (UIView *)superviewOrSelfWhichIsInstanceOfClass:(Class)class;
- (UIView *)subviewOrSelfWhichIsInstanceOfClass:(Class)class enumDirection:(NSEnumerationOptions)enumDirection;

- (void)removeAllSubviews;


@end


#pragma mark - Toast

extern NSString * const CSToastPositionTop;
extern NSString * const CSToastPositionCenter;
extern NSString * const CSToastPositionBottom;

@interface UIView (NIPAdditions_ToastAdditions)

// each makeToast method creates a view and displays it as toast
- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position image:(UIImage *)image;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title;
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title image:(UIImage *)image;

// displays toast with an activity spinner
- (void)makeToastActivity;
- (void)makeToastActivity:(id)position;
- (void)hideToastActivity;

// the showToast methods display any view as toast
- (void)showToast:(UIView *)toast;
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(id)point;
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(id)point
      tapCallback:(void(^)(void))tapCallback;
- (void)hideToast:(UIView *)toast;
- (void)hideToastWithMessage:(NSString *)message;
@end

#pragma mark - Action

@interface UIView (NIPIView_Action)

- (void)makeTapableWithTarget:(id)target action:(SEL)action;

@end

