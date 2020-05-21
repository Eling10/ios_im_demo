//
//  EMInviteGroupMemberViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/29.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：添加群成员控制器 🐾
 */

#import "EMInviteGroupMemberViewController.h"

#import "ELAvatarNameCell.h"

#import "ElingIM.h"
#import "UIView+ELExtension.h"
#import "UIScrollView+Refresh.h"

#import <XCMacros/XCMacros.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface EMInviteGroupMemberViewController ()<UITableViewDataSource, UITableViewDelegate>

/// 排除的成员列表
@property (strong, nonatomic) NSArray *excludeArray;
/// 已选择的数据
@property (strong, nonatomic) NSMutableArray *selectedArray;
/// 底部标签
@property (weak, nonatomic) UILabel *selectedLabel;

@end


static NSString *const cellIdentifier = @"ELAvatarNameCellIdentifier";

@implementation EMInviteGroupMemberViewController

- (instancetype)initWithExcludeArray:(NSArray<ELUserInformation *> *)excludeArray
{
    self = [super init];
    if (self) {
        _excludeArray = excludeArray;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
    
    /// 加载数据
    [self.tableView beginRefreshing];
    [self loadData];
}

#pragma mark - 💤 👀 LazyLoad Method 👀

LazyLoadMethod(selectedArray);

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout: UIRectEdgeNone];
    }

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.title = @"选择群组成员";

    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view);
        }
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(50));
    }];

    UILabel *label = [[UILabel alloc] init];
    self.selectedLabel = label;
    self.selectedLabel.font = [UIFont systemFontOfSize:17];
    self.selectedLabel.textColor = [UIColor blackColor];
    self.selectedLabel.numberOfLines = 2;
    self.selectedLabel.text = @"已选择群组成员( 0 )";
    [bottomView addSubview:self.selectedLabel];
    [self.selectedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(bottomView);
        make.left.equalTo(bottomView).offset(15);
    }];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(bottomView.mas_top);
    }];
}

#pragma mark - Data

- (void)loadData
{
    [self.dataSource removeAllObjects];

    if (self.memberList.count) {
        [self.dataSource addObjectsFromArray:[self _filterData:self.memberList]];
        [self.tableView reloadData];
        return;
    }
    
    // 获取全部联系人
    @weakify(self);
    [[ELClient sharedClient].contactManager getContactsWithCompletion:^(NSArray<ELUserInformation *> *aList, NSError *aError) {
        @strongify(self);
        [self.tableView endRefreshing];
        if (!aError) {
            [self.dataSource addObjectsFromArray:[self _filterData:aList]];
            [self.tableView reloadData];
        }
        [self.tableView reloadData];
    }];
}

/**
 *  过滤数据
 */
- (NSArray<ELUserInformation *> *)_filterData:(NSArray<ELUserInformation *> *)source
{
    NSMutableArray *mArr = [NSMutableArray array];
    if ([self.excludeArray count] > 0) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (ELUserInformation *user in source) {
            if (![[self.excludeArray valueForKeyPath:@"_userId"] containsObject:user.userId]) {
                [array addObject:user];
            }
        }
        [mArr addObjectsFromArray:array];
    } else {
        if (source) {
            [mArr addObjectsFromArray:source];
        }
    }
    return mArr;
}

#pragma mark - Action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction
{
    if (_doneCompletion) {
        _doneCompletion(self.selectedArray);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching) {
        return self.searchResults.count;
    }
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELAvatarNameCell *cell = (ELAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ELAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
        checkButton.tag = 100;
        [checkButton setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [checkButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
        checkButton.userInteractionEnabled = NO;
        cell.accessoryView = checkButton;
    }

    ELUserInformation *memberM = nil;
    if (self.isSearching) {
        memberM = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        memberM = [self.dataSource objectAtIndex:indexPath.row];
    }
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:memberM.avatarUrl] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
    cell.nameLabel.text = memberM.nickName;

    UIButton *checkButton = (UIButton *)cell.accessoryView;
    checkButton.selected = [[self.selectedArray valueForKeyPath:@"_userId"] containsObject:memberM.userId];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ELUserInformation *memberM = nil;
    if (self.isSearching) {
        memberM = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        memberM = [self.dataSource objectAtIndex:indexPath.row];
    }

    BOOL isChecked = [[self.selectedArray valueForKeyPath:@"_userId"] containsObject:memberM.userId];
    if (isChecked) {
        [self.selectedArray removeObject:memberM];
    } else {
        [self.selectedArray addObject:memberM];
    }

    ELAvatarNameCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *checkButton = (UIButton *)cell.accessoryView;
    checkButton.selected = !isChecked;
    self.selectedLabel.text = [NSString stringWithFormat:@"已选择群组成员( %@ )", @([self.selectedArray count])];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarCancelButtonAction:(ELSearchBar *)searchBar
{
    [super searchBarCancelButtonAction:searchBar];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    if (!self.isSearching) {
        return;
    }

    @weakify(self);
    [[ELRealtimeSearch shared] realtimeSearchWithSource:self.dataSource searchText:aString collationStringSelector:@selector(nickName) resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:results];
            [self.tableView reloadData];
        });
    }];
}

@end
