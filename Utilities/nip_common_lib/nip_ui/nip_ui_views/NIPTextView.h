//
//  NIPTextView.h
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPView.h"

/**
 *  支持placeholder的textView,用来取代NIPTextField
 */
@interface NIPTextView : NIPView  {
    BOOL _shouldDrawPlaceholder;
}

@property(nonatomic,readonly) UITextView *textView;

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