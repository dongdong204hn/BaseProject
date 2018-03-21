//
//  NIPUserViewController.m
//  NSIP
//
//  Created by Eric on 2017/6/21.
//  Copyright © 2017年 netease. All rights reserved.
//

#import "NIPUserViewController.h"
#import "NIPTestPageViewController.h"

@interface NIPUserViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation NIPUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    [self initViews];
    [self addConstraints];
}

- (void)initViews {
    [self.view addSubview:self.tableView];
}

- (void)addConstraints {
    [self.tableView autoPinEdgesToSuperviewEdges];
}


#pragma mark - UITableViewDelegate && DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"测试页面";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NIPTestPageViewController *testVC = [[NIPTestPageViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
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
