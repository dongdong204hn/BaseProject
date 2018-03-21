//
//  NIPCheckBoxView.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPCheckBoxView.h"

@implementation NIPCheckBoxView

@synthesize checkIconView=_checkIconView;
@synthesize textLabel=_textLabel;
@synthesize canUnselect=_canUnselect;
@synthesize textColor=_textColor;
@synthesize checkedTextColor = _checkedTextColor;

+ (NIPCheckBoxView *)checkBoxViewWithFrame:(CGRect)frame Text:(NSString *)text checkIcon:(UIImage *)checkIcon unCheckIcon:(UIImage *)unCheckIcon
{
    NIPCheckBoxView *checkBox = [[NIPCheckBoxView alloc] initWithFrame:frame];
    checkBox.checkIcon = checkIcon;
    checkBox.uncheckIcon = unCheckIcon;
    checkBox.textLabel.text = text;
    return checkBox;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
        
        _checkIconView =[[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_checkIconView];
         
        _textLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor =[UIColor clearColor];
        _textLabel.font =[UIFont systemFontOfSize:12.0f];
        [self addSubview:_textLabel];
        
        _canUnselect= YES;
        
    }
    return self;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (!self.checked&&textColor) {
        _textLabel.textColor =textColor;
    }
}

- (void)setCheckedTextColor:(UIColor *)checkedTextColor {
    _checkedTextColor = checkedTextColor;
    if (self.checked&&checkedTextColor) {
        _textLabel.textColor =checkedTextColor;
    }    
}

-(void)tapped:(UITapGestureRecognizer*)tap {
    if (tap.state == UIGestureRecognizerStateRecognized) {
        if (!self.canUnselect&&self.checked) {
            return;
        }
        self.checked = !self.checked;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    _checkIconView.highlighted = checked;
    if (checked&&self.checkedTextColor) {
        _textLabel.textColor = self.checkedTextColor;
    }
    if (!checked&&self.textColor) {
        _textLabel.textColor = self.textColor;
    }
}

-(void)layoutSubviews {
    CGSize imageSize = _checkIconView.highlightedImage.size;
    _checkIconView.frame = CGRectMake(0, (self.bounds.size.height-imageSize.height)/2, imageSize.width, imageSize.height);
    _textLabel.frame = CGRectMake(_checkIconView.frame.size.width+self.iconTextSpace, 0, self.bounds.size.width-imageSize.width-2, self.bounds.size.height);
}

-(void)setCheckIcon:(UIImage *)checkIcon {
    _checkIconView.highlightedImage = checkIcon;
    [self setNeedsLayout];
}

-(UIImage*)checkIcon {
    return _checkIconView.highlightedImage;
}

-(UIImage*)uncheckIcon {
    return _checkIconView.image;
}

-(void)setUncheckIcon:(UIImage *)uncheckIcon {
    _checkIconView.image = uncheckIcon;
}

@end



@implementation ZBCheckBoxGroup {
    NIPLayoutBase *_layoutView;
}

@dynamic checkedItem;
@dynamic checkedIndex;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _checkBoxArray = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

- (void)setLayoutType:(ZBLayoutType)layoutType {
    if (_layoutType!=layoutType) {
        _layoutType = layoutType;
        [_layoutView removeFromSuperview];
        _layoutView = [NIPLayoutBase layoutOfType:layoutType];
        _layoutView.frame = self.bounds;
        [self addSubview:_layoutView]; 
    }
}

- (void)resizeToContent {
    [_layoutView resizeToContent];
    self.size = _layoutView.size;
}


-(void)boxCheckChanged:(NIPCheckBoxView*)box {
    if (box.checked) {
        if (self.singleCheck) {
            [self unCheckOthers:box];
        }
    } else {
        if (self.atLeatOneCheck) {
            if (self.checkedItem==nil) {
                box.checked = YES;
            }
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSUInteger)checkedIndex {
    for (NIPCheckBoxView *boxView in _checkBoxArray) {
        if (boxView.checked) {
            return [_checkBoxArray indexOfObject:boxView];
        }
    }
    return NSNotFound;
}

-(void)setCheckedIndex:(NSUInteger)select {
    NIPCheckBoxView *box = [_checkBoxArray objectAtIndex:select];
    if (!box.checked) {
        box.checked = YES;
        if (self.singleCheck) {
            [self unCheckOthers:box];
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


-(void)unCheckOthers:(NIPCheckBoxView*)box {
    for (NIPCheckBoxView *boxView in _checkBoxArray) {
        if (boxView!=box) {
            boxView.checked = NO;
        }
    }
}

- (NIPCheckBoxView*)checkedItem {
    for (NIPCheckBoxView *boxView in _checkBoxArray) {
        if (boxView.checked) {
            return boxView;
        }
    }
    return nil;
}

-(void)addCheckBox:(NIPCheckBoxView*)box {
    [_checkBoxArray addObject:box];
    [_layoutView addSubview:box];
    [box addTarget:self action:@selector(boxCheckChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _layoutView.frame = self.bounds;
    [_layoutView layoutSubviews];
}

@end
