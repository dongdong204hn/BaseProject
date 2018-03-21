//
//  NIPWebViewController.m
//  NSIP
//
//  Created by Eric on 16/10/14.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPWebViewController.h"
#import "NIPWebToolBar.h"
#import "NIPURLHandler.h"
#import "NIPJSService.h"
#import "NIPCommonUtil.h"
#import "NIPUIFactoryChild.h"
#import "UIView+NIPBasicAdditions.h"
#import "nip_macros.h"

#import <WebKit/WKWebView.h>
#import <WebKit/WKNavigationAction.h>
#import <WebKit/WKNavigationDelegate.h>

@interface NIPWebViewController () <WKNavigationDelegate>


@property (nonatomic, strong) NIPJSService *jsBridgeService;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NIPWebToolBar *toolBar;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatior;  // 显示在右上角导航栏上的
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityView;       // 显示在contentView上的

@property (nonatomic, strong) UIBarButtonItem *backBtnItem;
@property (nonatomic, strong) UIBarButtonItem *closeBtnItem;

@property (nonatomic, strong) NSString *jumpURL;

@property (nonatomic, assign) BOOL backBtnEnabled;

@end

@implementation NIPWebViewController



#pragma mark - lifecyle

- (void)dealloc {
    _webView.navigationDelegate = nil;
    _jsBridgeService = nil;
}

- (void)loadView {
    [super loadView];
     [self registJSBridegeService];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self initAndAddWebView];
    [self initAndAddToolBar];
    [self initAndAddLoadIndicatorView];
    [self initAndAddLoadingActivityView];
     [_jsBridgeService connect:_webView withViewController:self];
    _backBtnEnabled = YES;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"web view controller ******  view  will  appear");
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.firstAppear) {
        [self layoutViews];
    }
    //把返回按钮行为放到这里，是因为基类里调用setBlueNavigationBar 会重新设返回按钮行为
    [self addCloseItemToNavigationBar];
   
//    [self.navigationController.navigationBar addSubview:_progressView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWebView) name:kCOOKIE_CHANGED object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.firstAppear) {
        [self layoutViews];
        if (self.startupRequest) {
            [_webView loadRequest:self.startupRequest];
        } else if (self.startupURLString) {
            if ([self.startupURLString hasPrefix:@"/Users"]) {
                [_webView loadHTMLString:[NSString stringWithContentsOfFile:self.startupURLString encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
                return;
            }
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.startupURLString]];
            [_webView loadRequest:request];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
//    [_progressView removeFromSuperview];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}



#pragma mark - JSBridge part

- (void)registJSBridegeService {
    if(!_jsBridgeService){
        _jsBridgeService = [[NIPJSService alloc] initBridgeServiceWithConfig:@"PluginConfig.json"];
    }
   
}


#pragma mark - action code

- (void)backBtnPressed:(id)sender {
    if (_backBtnEnabled) { //通过jsbridge设定返回按钮的行为，默认为回到上一页，如果设为false，则直接关闭webview
        if ([_webView canGoBack]) {
            [_webView goBack];
        } else{
            [self baseBackButtonPressed:nil];
        }
    } else{
        [self baseBackButtonPressed:nil];
    }
}

- (void)setBackButtonEnable:(BOOL)enable {
    _backBtnEnabled = enable;
}

- (void)reloadWebView{
    if (_jumpURL) {
//        NSURL *jump = [NIPCommonUtil redirectUrl:[NSURL URLWithString:_jumpURL]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_jumpURL]]];
    } else{
        [self.webView reload];
    }
}

- (BOOL)canMapUrlToLocalAction:(NSURL*)url {
//    if ([url.host isEqualToString:kLOGIN_URL_PAGE_NTES]) {
//        self.navigationController.navigationBar.userInteractionEnabled = NO;//如需打开内置登录页，临时禁用左上角返回，避免还没弹出登录时退出webview，还会弹登录，当关闭登录时界面层级发生错误
//        NSDictionary *urlDic = url.parametersDictionary;
//        if ([urlDic objectForKey:kLOGIN_URL_PARAM_JUMP]) {
//            jumpUrl = [urlDic objectForKey:kLOGIN_URL_PARAM_JUMP];
//        }
//        [self showLoginControllerWithSuccessBlock:^{
//            self.navigationController.navigationBar.userInteractionEnabled = YES;
//            [self reloadWebView];
//            
//        } cancelBlock:^{
//            self.navigationController.navigationBar.userInteractionEnabled = YES;
//        }];
//        return YES;
//    }
//    return [[CFURLHandler sharedHandler] openExternalUrl:url inController:self];
    return YES;
}


#pragma mark - WKNavigationDelegate methods

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL shouldLoad = NO;
    NSURL *reMapedURL = [NIPCommonUtil convertlinkUrl:navigationAction.request.URL];
    if ([navigationAction.request.URL.scheme isEqualToString:NSIP_PREFIX] ||
        [reMapedURL.scheme isEqualToString:NSIP_PREFIX]) {
        shouldLoad = [self canMapUrlToLocalAction:reMapedURL];
    } else if ([navigationAction.request.URL.scheme hasPrefix:@"http"]) {
        shouldLoad = YES;
    } else {
        shouldLoad = [[NIPURLHandler sharedHandler] openUrl:navigationAction.request.URL inController:self];
    }
    if (shouldLoad) {
         decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.toolBar refreshBarButtonItemStatus];
    [self.loadingIndicatior startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.toolBar refreshBarButtonItemStatus];
    [_loadingIndicatior stopAnimating];
    [self showCloseBtnItem:[_webView canGoBack]];
    if (!self.title) {
        [_webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
            self.title = item;
        }];
    }
    [_jsBridgeService readyWithEvent:@"LDMJsBridgeReady"];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.toolBar refreshBarButtonItemStatus];
    [_loadingIndicatior stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.toolBar refreshBarButtonItemStatus];
    [_loadingIndicatior stopAnimating];
}


#pragma mark - LoadingView control

- (void)showLoadingActivityView {
    [_loadingActivityView startAnimating];
}

- (void)hideLoadingActivityView {
    [_loadingActivityView stopAnimating];
}

- (void)setLoadingActivityViewColor:(UIColor *)color {
    _loadingActivityView.color = color;
}


#pragma mark - UI control

- (void)layoutViews {
    if (self.hideToolBar) {
        self.toolBar.hidden = YES;
        _webView.frame = _webView.superview.bounds;
    } else {
        self.toolBar.hidden = NO;
        _webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.contentView.height - 44);
        _toolBar.frame = CGRectMake(0, self.contentView.height - 44, SCREEN_WIDTH, 44);
    }
}

- (void)addCloseItemToNavigationBar {
    if (!_backBtnItem) {
        UIButton *backBtn = [NIPUIFactoryChild naviBackButtonWithTarget:self selector:@selector(backBtnPressed:)];
        _backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
    if (!_closeBtnItem) {
        _closeBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(baseBackButtonPressed:)];
    }
    
    [self showCloseBtnItem:[_webView canGoBack]];
    self.navigationItem.leftBarButtonItems = @[_backBtnItem, _closeBtnItem];
}

-(void)showCloseBtnItem:(BOOL)show
{
    if (show) {
        _closeBtnItem.style = UIBarButtonItemStylePlain;
        _closeBtnItem.enabled = true;
        _closeBtnItem.title = @"关闭";
        [_closeBtnItem setTintColor:[UIColor whiteColor]];
    } else {
        _closeBtnItem.style = UIBarButtonItemStylePlain;
        _closeBtnItem.enabled = false;
        _closeBtnItem.title = nil;
        [_closeBtnItem setTintColor:[UIColor clearColor]];
    }
}

- (void)initAndAddWebView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        _webView.navigationDelegate = self;
        
        [self.contentView addSubview:_webView];
    }
}

- (void)initAndAddToolBar {
    if (!_toolBar) {
        _toolBar = [NIPWebToolBar initWithWebView:_webView];
        [self.contentView addSubview:_toolBar];
    }
}

- (void)initAndAddLoadIndicatorView {
    if (!_loadingIndicatior) {
        _loadingIndicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingIndicatior.hidesWhenStopped = YES;
        UIView *wrapView = [[UIView alloc] initWithFrame:_loadingIndicatior.frame];
        wrapView.width += 10;
        [wrapView addSubview:_loadingIndicatior];
        self.naviRightView = wrapView;
    }
}

- (void)initAndAddLoadingActivityView {
    _loadingActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingActivityView.hidesWhenStopped = YES;
    _loadingActivityView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
    [self.view addSubview:_loadingActivityView];
}


#pragma mark - Setters

@end
