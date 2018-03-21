//
//  NIPTextField.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

/**
 *  NIPTextField为UITextView增加了placeHolder支持
 */
@interface NIPTextField : UITextView  {
    BOOL _shouldDrawPlaceholder;
}

@property(nonatomic,strong) UIImage *background;

/**
 The string that is displayed when there is no other text in the text view.
 
 The default value is `nil`.
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 The color of the placeholder.
 
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic, strong) UIColor *placeholderColor;

@end