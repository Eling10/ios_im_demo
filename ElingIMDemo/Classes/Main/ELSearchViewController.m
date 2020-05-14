//
//  ELSearchViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/29.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：搜索控制器 🐾
 */

#import "ELSearchViewController.h"
#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>

@interface ELSearchViewController ()

@end

@implementation ELSearchViewController

- (void)dealloc
{
    [[ELRealtimeSearch shared] realtimeSearchStop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ELSearchBar *searchBar = [[ELSearchBar alloc] init];
    self.searchBar = searchBar;
    self.searchBar.placeholder = @"请输入用户名";
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    UITableView *tableView = [[UITableView alloc] init];
    self.tableView = tableView;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - 💤 👀 LazyLoad Method 👀

LazyLoadMethod(searchResults);

#pragma mark - ELSearchBarDelegate

- (void)searchBarShouldBeginEditing:(ELSearchBar *)searchBar
{
    if (!self.isSearching) {
        self.isSearching = YES;
    }
}

- (void)searchBarCancelButtonAction:(ELSearchBar *)searchBar
{
    [[ELRealtimeSearch shared] realtimeSearchStop];
    self.isSearching = NO;
    [self.searchResults removeAllObjects];
}

@end
