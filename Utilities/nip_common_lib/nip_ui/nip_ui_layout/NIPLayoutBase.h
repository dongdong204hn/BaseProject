//
//  NIPLayoutBase.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "nip_ui_util.h"
#import "NIPView.h"

typedef NS_ENUM(NSUInteger, ZBLayoutOptionMask)  {
    ZBLayoutOptionAlignmentLeft = 1,
    ZBLayoutOptionAlignmentRight = 2,
    ZBLayoutOptionAlignmentCenter = 1<<2,
    ZBLayoutOptionAlignmentTop = 1<<3,
    ZBLayoutOptionAlignmentBottom = 1<<4,
    
    ZBLayoutOptionAutoResize = 1<<8,
    ZBLayoutOptionAutoResizeShrink =1<<9,
    ZBLayoutOptionAutoResizeExpand =1<<10,
    
    ZBLayoutOptionDontLayout = 1<<12
};

typedef NS_ENUM(NSUInteger, ZBLayoutType)  {
    ZBLayoutTypeHorizon = 1,
    ZBLayoutTypeVertical = 2,
    ZBLayoutTypeGrid = 3
};

@interface NIPLayoutItem : NSObject
@property(nonatomic,strong) UIView *view;
@property(nonatomic) CGFloat spacing;
@property(nonatomic) ZBLayoutOptionMask layoutOptionMask;
- (BOOL)isEqual:(id)object;
@end

@interface NIPLayoutBase : NIPView {
@protected
    NSMutableArray *_layoutItems;
}
@property(nonatomic) NSUInteger contentLayoutOption;
@property(nonatomic) NSUInteger defaultSubViewLayoutOption;
@property(nonatomic) CGFloat defaultSpacing;
@property(nonatomic) UIEdgeInsets contentInsets;

//下面四个属性兼容老代码，建议不用
@property(nonatomic) CGFloat leftPad;
@property(nonatomic) CGFloat rightPad;
@property(nonatomic) CGFloat topPad;
@property(nonatomic) CGFloat bottomPad;


@property(nonatomic) CGSize minimumSize; //size limit when resizeToContent
@property(nonatomic) CGSize maximumSize; //size limit when resizeToContent
@property(nonatomic,readonly) NSInteger layoutableSubviewCount;

+ (NIPLayoutBase*)layoutOfType:(ZBLayoutType)type;

- (void)addSubview:(UIView*)subview withSpace:(CGFloat)space option:(ZBLayoutOptionMask)option;
- (void)addSubview:(UIView*)subview withSpace:(CGFloat)space;
- (void)addSubview:(UIView*)subview withOpion:(ZBLayoutOptionMask)option;
- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index;
- (void)insertSubview:(UIView*)subview withSpace:(CGFloat)space option:(ZBLayoutOptionMask)option atIndex:(NSInteger)index;
- (void)moveSubview:(UIView*)subView toIndex:(NSInteger)toIndex;
- (void)removeSubView:(UIView*)subView;
- (void)removeAllSubViews;

- (NSUInteger)indexOfSubView:(UIView*)subView;

- (void)resizeToContent;
- (CGSize)neededSizeForContent;

@end
