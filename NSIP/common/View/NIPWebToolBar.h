//
//  NIPWebToolBar.h
//  NSIP
//
//  Created by Eric on 16/10/14.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKWebView.h>

@interface NIPWebToolBar : UIToolbar

+ (instancetype)initWithWebView:(WKWebView *)webView;

- (void)refreshBarButtonItemStatus;

@end
