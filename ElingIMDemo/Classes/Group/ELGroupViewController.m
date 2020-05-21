//
//  ELGroupViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/29.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：群控制器 🐾
 */

#import "ELGroupViewController.h"

#import "ELChatViewController.h"
#import "EMInviteGroupMemberViewController.h"
#import "ELNavigationController.h"
#import "ELCreateGroupViewController.h"
#import "ELChatViewController.h"

#import "ELAvatarNameCell.h"

#import "ElingIM.h"
#import "ELUtilMacros.h"
#import "ELColorMacros.h"
#import "UIScrollView+Refresh.h"
#import "UIView+ELExtension.h"

#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ELGroupViewController ()<UITableViewDataSource, UITableViewDelegate, ELGroupManagerDelegate>

@property (weak, nonatomic) UITableView *tableView;

@end


static NSString *const ELAvatarNameCellIdentifier = @"ELAvatarNameCellIdentifier";

@implementation ELGroupViewController

- (void)dealloc
{
    [[ELClient sharedClient].groupManager removeDelegate:self];
    [NOTIFICATION_CENTER removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置UI
    [self setupUI];
    
    /// 注册通知
    [self registerNotification];
    
    [self.tableView beginRefreshing];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"我的群组";
    
    // tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.separatorColor = ELCELL_SEPRATOR_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    @weakify(self);
    self.tableView.loadNewDataHandle = ^{
        @strongify(self);
        [self loadData];
    };
}

#pragma mark - 👀 Notification 👀 💤

- (void)registerNotification
{
    /// 添加群组管理代理
    [[ELClient sharedClient].groupManager addDelegate:self];
    
    /// 群组信息修改成功的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:EL_GROUP_UPDATE_SUCCESS object:nil];
    /// 退群、解散群组的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:EL_GROUP_EXIT_SUCCESS object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:EL_GROUP_DISSOLUTION_SUCCESS object:nil];
}

#pragma mark - 👀 加载数据 👀 💤

- (void)loadData
{
    @weakify(self);
    [[ELClient sharedClient].groupManager getGroups:^(NSArray<ELUserInformation *> *aList, NSError *aError) {
        @strongify(self);
        [self.tableView endRefreshing];
        if (!aError) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:aList];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  创建群组
 */
- (void)_createGroup
{
    // 跳转到创建群组控制器
    ELCreateGroupViewController *vc = [[ELCreateGroupViewController alloc] init];
    @weakify(self);
    // 创建成功，刷新列表
    vc.successCompletion = ^{
        @strongify(self);
        [self.tableView beginRefreshing];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)   return 1;
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELAvatarNameCell *cell = [tableView dequeueReusableCellWithIdentifier:ELAvatarNameCellIdentifier];
    if (!cell) {
        cell = [[ELAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ELAvatarNameCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"group"];
            cell.nameLabel.text = @"创建群组";
            cell.nameLabel.font = [UIFont systemFontOfSize:18];
        }
        return cell;
    }
    ELGroup *group = [self.dataSource objectAtIndex:indexPath.row];
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString: group.groupAvatar] placeholderImage:[UIImage imageNamed:@"group_default"]];
    cell.nameLabel.text = group.groupName;
    cell.nameLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 20;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = self.view.backgroundColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {   // 创建群组
        [self _createGroup];
        return;
    }
    
    // 发起群聊
    ELGroup *group = self.dataSource[indexPath.row];
    ELChatViewController *vc = [[ELChatViewController alloc] initWithConversationId:group.groupId type:ELChatTypeGroupChat toName:group.groupName toAvatar:group.groupAvatar];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 💉 👀 ELGroupManagerDelegate 👀

/**
 *  当群被解散的通知（群主不会收到此回调）
 *
 *  @param groupId 群ID
 */
- (void)groupDidDissolution:(NSString *)groupId
{
    // 刷新列表
    [self loadData];
}

/**
 *  自己被移出群组的通知（自己主动退群的不会收到此回调）
 *
 *  @param aGroupId 群组ID
 */
- (void)userDidDeleteFromGroup:(NSString *)aGroupId
{
    // 刷新列表
    [self loadData];
}

@end
