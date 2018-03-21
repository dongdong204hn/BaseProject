//
//  NIPWebToolBar.m
//  NSIP
//
//  Created by Eric on 16/10/14.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPWebToolBar.h"
#import "UIView+NIPBasicAdditions.h"


@interface NIPWebToolBar ()

@property (nonatomic, weak) WKWebView *webView;

@property (nonatomic, strong) UIBarButtonItem *backwardBtn;
@property (nonatomic, strong) UIBarButtonItem *forwardBtn;
@property (nonatomic, strong) UIBarButtonItem *refreshBtn;
@property (nonatomic, strong) UIBarButtonItem *spaceBtn;


@end

@implementation NIPWebToolBar

+ (instancetype)initWithWebView:(WKWebView *)webView {
    NIPWebToolBar *toolBar = [[super alloc] init];
    toolBar.webView = webView;
    toolBar.frame = CGRectMake(0, 0, webView.width, 44);
    [toolBar setBackgroundImage:[UIImage imageNamed:@"toolBackground"] forToolbarPosition:(UIBarPositionAny) barMetrics:UIBarMetricsDefault];
    [toolBar addBarButtonItems];
    return toolBar;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)addBarButtonItems {
//    _backwardBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(actionForBarButtonItem:)];
    _backwardBtn = [[UIBarButtonItem alloc] initWithImage:[self drawBackBtnImage] style:UIBarButtonItemStylePlain target:self action:@selector(actionForBarButtonItem:)];
    _forwardBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(actionForBarButtonItem:)];
    _refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionForBarButtonItem:)];
    _spaceBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttonArray=[NSArray arrayWithObjects:_backwardBtn, _spaceBtn, _forwardBtn, _spaceBtn, _refreshBtn,nil];
    [self setItems:buttonArray];
}

- (void)actionForBarButtonItem:(id)sender {
    if (_backwardBtn == sender) {
        [_webView goBack];
    } else if (_forwardBtn == sender) {
        [_webView goForward];
    } else if (_refreshBtn == sender) {
        [_webView reload];
    }
}

- (void)refreshBarButtonItemStatus {
    _backwardBtn.enabled = [_webView canGoBack];
    _forwardBtn.enabled = [_webView canGoForward];
}

- (UIImage *)drawBackBtnImage {
    CGRect iconRect = CGRectMake(0, 0, 18*1.732/2, 18+5);
    UIGraphicsBeginImageContextWithOptions(iconRect.size,NO,2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    const CGFloat color[] = {1.0,1.0,1.0,1.0};
    CGContextSetFillColor(context, color);
    iconRect.origin.y = 5;
    iconRect.size.height = 18;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, iconRect.origin.x,iconRect.origin.y+iconRect.size.height/2);
    CGContextAddLineToPoint(context, iconRect.origin.x+iconRect.size.width, iconRect.origin.y);
    CGContextAddLineToPoint(context, iconRect.origin.x+iconRect.size.width, iconRect.origin.y+iconRect.size.height);
    CGContextAddLineToPoint(context, iconRect.origin.x,iconRect.origin.y+iconRect.size.height/2);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
