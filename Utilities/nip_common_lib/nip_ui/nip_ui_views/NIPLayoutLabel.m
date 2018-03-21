//
//  NIPLayoutLabel.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import<CoreText/CoreText.h>
#import "NIPLayoutLabel.h"

@implementation NIPLayoutLabel {
    CTFramesetterRef _frameSetter;
    NSAttributedString *_attributedString;
}

@synthesize characterSpacing = characterSpacing_;
@synthesize linesSpacing = linesSpacing_;

-(id) initWithFrame:(CGRect)frame
{
    //初始化字间距、行间距
    if(self =[super initWithFrame:frame]) {
        self.characterSpacing = 0.0f;
        self.linesSpacing = 5.0f;
    }
    return self;
}



-(void)setCharacterSpacing:(CGFloat)characterSpacing //外部调用设置字间距
{
    characterSpacing_ = characterSpacing;
    [self setNeedsDisplay];
}



-(void)setLinesSpacing:(CGFloat)linesSpacing  //外部调用设置行间距
{
    linesSpacing_ = linesSpacing;
    [self setNeedsDisplay];
}


- (NSAttributedString*)attributedString {
    if (!_attributedString) {
        //创建AttributeString
        NSMutableAttributedString *string =[[NSMutableAttributedString alloc]initWithString:self.text];
        
        //设置字体及大小
        CTFontRef helveticaBold = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName,self.font.pointSize,NULL);
        [string addAttribute:(id)kCTFontAttributeName value:(__bridge id)helveticaBold range:NSMakeRange(0,[string length])];
        CFRelease(helveticaBold);
        
        //设置字间距
        if(self.characterSpacing)
        {
            float number = self.characterSpacing;
            CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberFloatType,&number);
            [string addAttribute:(__bridge id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0,[string length])];
            CFRelease(num);
        }
        
        //设置字体颜色
        [string addAttribute:(id)kCTForegroundColorAttributeName value:(id)(self.textColor.CGColor) range:NSMakeRange(0,[string length])];
        
        //创建文本对齐方式
        CTTextAlignment alignment = kCTLeftTextAlignment;
        if(self.textAlignment == NSTextAlignmentCenter)
        {
            alignment = kCTCenterTextAlignment;
        }
        else if(self.textAlignment == NSTextAlignmentRight)
        {
            alignment = kCTRightTextAlignment;
        }
        else if (self.textAlignment == NSTextAlignmentJustified) {
            alignment = kCTTextAlignmentJustified;    
        }
        
        CTParagraphStyleSetting alignmentStyle;
        alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
        alignmentStyle.valueSize = sizeof(alignment);
        alignmentStyle.value = &alignment;
        
        //设置文本行间距
        CGFloat lineSpace = self.linesSpacing;
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
        lineSpaceStyle.valueSize = sizeof(lineSpace);
        lineSpaceStyle.value =&lineSpace;
        
        //设置文本段间距
        CGFloat paragraphSpacing = self.paragraphSpacing;
        CTParagraphStyleSetting paragraphSpaceStyle;
        paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
        paragraphSpaceStyle.valueSize = sizeof(CGFloat);
        paragraphSpaceStyle.value = &paragraphSpacing;
        
        CTParagraphStyleSetting paragraphIndentSpaceStyle;
        CGFloat paragraphIndentSpacing = self.paragraphIndentSpacing;
        paragraphIndentSpaceStyle.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
        paragraphIndentSpaceStyle.valueSize = sizeof(CGFloat);
        paragraphIndentSpaceStyle.value = &paragraphIndentSpacing;
        
        //创建设置数组
        CTParagraphStyleSetting settings[ ] ={alignmentStyle,lineSpaceStyle,paragraphSpaceStyle,paragraphIndentSpaceStyle};
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings , sizeof(settings)/sizeof(CTParagraphStyleSetting));
        
        //给文本添加设置
        [string addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0 , [string length])];
        CFRelease(style);
        
        _attributedString = string;
    }
    return _attributedString;
}

- (CTFramesetterRef)framesetter {
    if (!_frameSetter) {
        _frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)[self attributedString]);
    }
    return _frameSetter;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CTFramesetterSuggestFrameSizeWithConstraints([self framesetter],
                                                        CFRangeMake(0, [[self attributedString] length]), NULL,
                                                        size, NULL);
}

-(void) drawTextInRect:(CGRect)requestedRect
{
    //排版
    [self.textColor setStroke];
    
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGPathAddRect(leftColumnPath, NULL ,CGRectMake(0 , 0 ,self.bounds.size.width , self.bounds.size.height));
    
    CTFrameRef leftFrame = CTFramesetterCreateFrame([self framesetter],CFRangeMake(0, 0), leftColumnPath , NULL);
    
    //翻转坐标系统（文本原来是倒的要翻转下）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    CGContextTranslateCTM(context , 0 ,self.bounds.size.height);
    CGContextScaleCTM(context, 1.0 ,-1.0);
    
    if (self.shadowColor) {
        CGContextSetShadowWithColor(context,self.shadowOffset,self.shadowOffset.height,[[UIColor colorWithRed:0xff/255.0f green:0xff/255.0f blue:0xff/255.0f alpha:1.0f] CGColor]);
    }

    
    //画出文本
    CTFrameDraw(leftFrame,context);
    
    //释放
    CFRelease(leftFrame);
    CGPathRelease(leftColumnPath);
}

- (void)dealloc {
    if (_frameSetter) {
        CFRelease(_frameSetter);
    }
}

@end

