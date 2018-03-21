//
//  NIPInputViewTranslator.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NIPInputViewTranslateType) {
    NIPInputViewTranslateRelative = 0, //确保每个inputView获得焦点时，全部完整露出
    NIPInputViewTranslateStatic //当有inputView获得焦点时，translate一个固定的距离
};

/**
 *  当视图中包含输入框，比如UITextField或UITextView的时候，这个类可以提供自动的视图移动，以保持输入框露出
 */
@interface NIPInputViewTranslator : NSObject
//default NIPInputViewTranslateRelative
@property(nonatomic) NIPInputViewTranslateType translateType;

//在输入控件底部和键盘顶部之间保留的距离
@property(nonatomic) CGFloat translateOffset;

//包含输入控件的父view，当input获得焦点时，会调整该view的位置来确保input露出，不要将该属性设置为controller.view,因为系统在某些情况下会自动设置controller.view的frame，造成混乱
@property(nonatomic,weak) UIView *inputViewContainer;

//defualt YES,一个inputView完成输入时，是否跳到下一个inputView，inputView之间的相对顺序是他们在整个View树形结构总的顺序。
@property(nonatomic) BOOL autoActivateNextInputView;

//defualt NO,UITextView是否允许输入换行，如果不允许的话，当输入Returnkey时，完成该inputView的输入。
@property(nonatomic) BOOL textViewAllowLineBreak;

- (void)addTextFiled:(UITextField*)input;
- (void)addTextView:(UITextView*)input;
- (void)cancelAllInputView;
@end
