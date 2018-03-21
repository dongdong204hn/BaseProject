//
//  NIPInputViewTranslator.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPInputViewTranslator.h"
#import "nip_ui_additions.h"

@implementation NIPInputViewTranslator

- (id)init {
    if (self=[super init]) {
        self.translateOffset = -5;
        self.autoActivateNextInputView = YES;
        self.textViewAllowLineBreak = NO;
    }
    return self;
}

- (void)addTextFiled:(UITextField*)textFiled {
    [textFiled addTarget:self action:@selector(textFieldDidBeginEditing:)
        forControlEvents:UIControlEventEditingDidBegin];
    [textFiled addTarget:self action:@selector(textFieldDidEndEditing:)
        forControlEvents:UIControlEventEditingDidEndOnExit];
    [textFiled addTarget:self action:@selector(textFieldDidCancel:)
        forControlEvents:UIControlEventEditingDidEnd];
}

- (void)addTextView:(UITextView*)input {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:input];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEndEditing:) name:UITextViewTextDidEndEditingNotification object:input];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:input];
}

- (void)cancelAllInputView {
    [[_inputViewContainer findFirstResponder] resignFirstResponder];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelAllInputView];
}

#pragma mark
#pragma mark textFiled support

- (void)textFieldDidBeginEditing:(id)sender {
    [self inputViewDidBegin:sender];
}

- (void)textFieldDidEndEditing:(id)sender {
    [self inputViewDidEnd:sender];
    if(self.autoActivateNextInputView) {
        UIView<UITextInput> *nextInputView = [self nextInputViewAfter:sender];
        if (nextInputView) {
            [nextInputView becomeFirstResponder];
        }
    }
}

- (void)textFieldDidCancel:(id)sender {
    [self inputViewDidEnd:sender];   
}

#pragma mark
#pragma mark textview support

- (void)textViewBeginEditing:(NSNotification*)note {
    [self inputViewDidBegin:note.object];
}

- (void)textViewEndEditing:(NSNotification*)note {
    [self inputViewDidEnd:note.object];
}

- (void)textViewChanged:(NSNotification*)note {
    UITextView *textView = (UITextView*)note.object;
    NSString *text = textView.text;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (textView.text.length!=text.length) {
        textView.text = text;
        [textView resignFirstResponder];
        if(self.autoActivateNextInputView) {
            UIView<UITextInput> *nextInputView = [self nextInputViewAfter:textView];
            if (nextInputView) {
                [nextInputView becomeFirstResponder];
            }
        }
    }
}

#pragma mark find InputView

//找出view hierachy中位于view右侧的inputView
//相当于从view节点开始，对树的进行后序遍历，假定Inputview不可能嵌套
- (UIView<UITextInput> *)nextInputViewAfter:(UIView*)view {
    NSArray *array = [[view superview] subviews];
    if (array) {
        //在排在后面的兄弟节点中找
        NSUInteger indexOfCurrentView = [array indexOfObject:view];
        for (NSUInteger i=indexOfCurrentView+1; i<array.count; i++) {
            UIView<UITextInput> *inputView = [self inputViewUnderSuperview:array[i]];
            if (inputView) {
                return inputView;
            }
        }
        
        //回退上一级，继续往右需找
        view = [view superview];
        return [self nextInputViewAfter:view];
    }
    return nil;
}

- (UIView<UITextInput> *)inputViewUnderSuperview:(UIView*)superView {
    if ([superView conformsToProtocol:@protocol(UITextInput)]) {
        return (UIView<UITextInput>*)superView;
    }
    for (UIView *subView in superView.subviews) {
        if ([subView conformsToProtocol:@protocol(UITextInput)]) {
            return (UIView<UITextInput>*)subView;
        } else {
            UIView<UITextInput> *inputView = [self inputViewUnderSuperview:subView];
            if (inputView) {
                return inputView;
            }
        }
    }
    return nil;
}

#pragma mark
#pragma mark container transform

- (void)inputViewDidBegin:(UIView<UITextInput> *)sender {
    CGFloat KeyBoardHeight = 255;
    if (sender.keyboardType==UIKeyboardTypeNumberPad
        ||sender.keyboardType==UIKeyboardTypePhonePad
        ||sender.keyboardType==UIKeyboardTypeNumbersAndPunctuation) {
        KeyBoardHeight = 215;
    }
    if (self.translateType==NIPInputViewTranslateRelative) {
        CGAffineTransform currentTransform = self.inputViewContainer.transform;
        CGRect editorFrameInView = [self.inputViewContainer.window convertRect:sender.bounds fromView:sender];
        editorFrameInView = CGRectApplyAffineTransform(editorFrameInView, CGAffineTransformInvert(currentTransform));
        CGFloat offset = self.inputViewContainer.window.height-KeyBoardHeight-sender.inputAccessoryView.height-CGRectGetMaxY(editorFrameInView)+self.translateOffset;
        if (offset<0.01) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.inputViewContainer.transform = CGAffineTransformMakeTranslation(0,offset);
                             }];
        } else if  (!CGAffineTransformIsIdentity(currentTransform)) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.inputViewContainer.transform = CGAffineTransformIdentity;
                             }];
        }
    } else {
        if  (CGAffineTransformIsIdentity(self.inputViewContainer.transform)) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.inputViewContainer.transform = CGAffineTransformMakeTranslation(0, self.translateOffset);
                             }];
        }
    }
}

- (void)inputViewDidEnd:(UIControl<UITextInput> *)sender {
    [self performSelector:@selector(restoreViewTransformAfterInput) withObject:nil afterDelay:0];
}

- (void)restoreViewTransformAfterInput {
    if  (!CGAffineTransformIsIdentity(self.inputViewContainer.transform)
        && [self.inputViewContainer findFirstResponder] == nil) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.inputViewContainer.transform = CGAffineTransformIdentity;
                         }];
    }
}

@end
