//
//  ELInviteFriendViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：添加好友控制器 🐾
 */


#import "ELInviteFriendViewController.h"

#import "ELInviteFriendAlertController.h"

#import "ElingIM.h"
#import "ELSearchBar.h"
#import "ELAvatarNameCell.h"

#import <XCMacros/XCMacros.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCProgressHUD/UIView+XCProgressHUD.h>
#import <XCPresentation/XCPresentation.h>
#import <XCPresentation/XCPresentationAlertAnimation.h>

#define kColor_Gray [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0]
#define kColor_Blue [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0]


@interface ELInviteFriendViewController ()<ELSearchBarDelegate, UITableViewDataSource>

@property (nonatomic, weak) ELSearchBar *searchBar;
@property (nonatomic, weak) UITableView *tableView;
/// 邀请人员列表
@property (nonatomic, strong) NSMutableArray *invitedUsers;

@end


static NSString *const ELAvatarNameCellIdentifier = @"ELAvatarNameCellIdentifier";

@implementation ELInviteFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /// 设置UI
    [self setupUI];
}

#pragma mark - 💤 👀 LazyLoad Method 👀

LazyLoadMethod(invitedUsers);

#pragma mark - 👀 设置UI 👀 💤

- (void)setupUI
{
    self.title = @"添加好友";
    
    // 搜索框
    ELSearchBar *searchBar = [[ELSearchBar alloc] init];
    self.searchBar = searchBar;
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    // tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
}

#pragma mark - 👀 加载数据 👀 💤

- (void)loadData
{
    @weakify(self);
    [[ELClient sharedClient].contactManager searchContactWithUsername:self.searchBar.textField.text completion:^(NSArray<ELUserInformation *> *aList, NSError *aError) {
        @strongify(self);
        if (!aError) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:aList];
            [self.tableView reloadData];
        } else {
            [self.view showText:@"您搜索的用户不存在"];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELAvatarNameCell *cell = (ELAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:ELAvatarNameCellIdentifier];
    if (cell == nil) {
        cell = [[ELAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ELAvatarNameCellIdentifier];
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 35)];
        rightButton.clipsToBounds = YES;
        rightButton.backgroundColor = kColor_Blue;
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        rightButton.layer.cornerRadius = 5;
        [rightButton setTitle:@"添加好友" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cell.accessoryButton = rightButton;
    }
    
    ELUserInformation *infoM = [self.dataSource objectAtIndex:indexPath.row];
    cell.nameLabel.text = infoM.nickName;
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:infoM.avatarUrl] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
    cell.indexPath = indexPath;

    if (infoM.isFriend) {
        cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已添加" forState:UIControlStateDisabled];
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else if ([self.invitedUsers containsObject:infoM.userId]) {
         cell.accessoryButton.enabled = NO;
        [cell.accessoryButton setTitle:@"已申请" forState:UIControlStateDisabled];
        cell.accessoryButton.backgroundColor = kColor_Gray;
    } else {
        cell.accessoryButton.enabled = YES;
        cell.accessoryButton.backgroundColor = kColor_Blue;
    }
    
    @weakify(self);
    cell.clickAccessoryButtonCallback = ^{
        @strongify(self);
        if([infoM.userId isEqualToString:[ELClient sharedClient].userManager.currentUser.userId]) {
            [self.view showText:@"无法添加自己为好友"];
            return;
        }
        // 弹出添加好友对话框
        [self _showAlert:infoM.userId];
    };
    
    return cell;
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  显示添加弹出框
 *
 *  @param userId 用户ID
 */
- (void)_showAlert:(NSString *)userId
{
    ELInviteFriendAlertController *vc = [[ELInviteFriendAlertController alloc] init];
    @weakify(self);
    vc.clickEnterButtonCallback = ^(NSString *text) {
        @strongify(self);
        [[ELClient sharedClient].contactManager addContact:userId message:text completion:^(NSError *aError) {
            if (aError) {
                [self.view showText:@"添加失败"];
            } else {
                [self.view showText:@"已发出好友申请"];
                [self.invitedUsers addObject:userId];
                [self.tableView reloadData];
            }
        }];
    };
    XCPresentationAlertAnimation *animation = [XCPresentationAlertAnimation new];
    [XCPresentation presentWithPresentationAnimation:animation presentedViewController:vc presentingViewController:self.navigationController];
}
                
#pragma mark - EMSearchBarDelegate
                
- (void)searchBarCancelButtonAction:(ELSearchBar *)searchBar
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
}
                
- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    [self.view endEditing:YES];
    if ([aString length] > 0) {
        // 加载数据
        [self loadData];
    }
}

@end
