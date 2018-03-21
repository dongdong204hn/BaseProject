//
//  NIPTestPageViewController.m
//  NSIP
//
//  Created by Eric on 2016/12/19.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPTestPageViewController.h"
#import "NIPWebViewController.h"

@interface NIPTestPageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *testCaseArray;

@end

@implementation NIPTestPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试页面";
    [self initData];
    [self initViews];
    [self addConstraints];
}

- (void)initData {
    self.testCaseArray = @[
                           @{@"title":@"JSBridge测试",
                             @"selector":@"startJSBridgeTestCase"}
                           ];
}

- (void)initViews {
    [self.view addSubview:self.tableView];
}

- (void)addConstraints {
    [self.tableView autoPinEdgesToSuperviewEdges];
}


#pragma mark - UITableViewDelegate && DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testCaseArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.testCaseArray[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectorName = self.testCaseArray[indexPath.row][@"selector"];
    SEL selector = NSSelectorFromString(selectorName);
    [self performSelector:selector withObject:nil afterDelay:0];
}


#pragma mark - Test case

- (void)startJSBridgeTestCase {
    NIPWebViewController *webViewController = [[NIPWebViewController alloc] init];
    NSString *demohtmlPath = [[NSBundle mainBundle] pathForResource:@"api.htm" ofType:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:demohtmlPath]) {
        webViewController.startupURLString = demohtmlPath;
    }
    [self.navigationController pushViewController:webViewController animated:YES];
}


#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.height, self.view.width) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return _tableView;
}



@end
