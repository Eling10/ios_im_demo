//
//  ELSearchViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/29.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：搜索控制器 🐾
 */

#import "ELBaseViewController.h"
#import "ELSearchBar.h"
#import "ELRealtimeSearch.h"

@interface ELSearchViewController : ELBaseViewController<ELSearchBarDelegate>

/// 标记是否正在搜索
@property (nonatomic) BOOL isSearching;

@property (weak, nonatomic) UITableView *tableView;

/// 搜索框
@property (nonatomic, weak) ELSearchBar *searchBar;
/// 搜索结果
@property (nonatomic, strong) NSMutableArray *searchResults;

@end
