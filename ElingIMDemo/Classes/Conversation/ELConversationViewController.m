//
//  ELConversationViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELConversationViewController.h"
#import "ELConversationCell.h"
#import "ELChatViewController.h"

#import "ELUtilMacros.h"
#import "ELColorMacros.h"
#import "ELConversationHelper.h"
#import "UIScrollView+Refresh.h"
#import "UIView+ELExtension.h"

#import <XCMacros/XCMacros.h>
#import <Masonry/Masonry.h>
#import <ElingIM/ELClient.h>
#import <ElingIM/ELConversation.h>

@interface ELConversationViewController ()<ELChatManagerDelegate, ELGroupManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;

@end

@implementation ELConversationViewController

- (void)dealloc
{
    // 移除通知
    [self removeNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 配置聊天相关的数据
    [self setupIM];
    
    // 设置 UI
    [self setupUI];
    
    // 添加通知
    [self addNotification];
}

#pragma mark - 👀 IM 👀 💤

- (void)setupIM
{
    [[ELClient sharedClient].chatManager addDelegate:self];
    [[ELClient sharedClient].groupManager addDelegate:self];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"聊天";
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
    // 开始刷新
    [self.tableView beginRefreshing];
}

#pragma mark - 👀 Notification 👀 💤

- (void)addNotification
{
    /// 消息未读数清零的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(conversationUnreadCountToZero) name:ELCONVERSATION_UNREAD_COUNT_TO_ZERO object:nil];
    /// 消息发送成功的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:ELMESSAGE_SEND_SUCCESS object:nil];
    /// 通话结束的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:ELCALL_END object:nil];
    /// 群被解散、或者被移出当前群聊
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:EL_GROUP_EXIT_SUCCESS object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:EL_GROUP_DISSOLUTION_SUCCESS object:nil];
    /// 好友删除成功的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(loadData) name:EL_CONTACT_DELETE_SUCCESS object:nil];
}

- (void)removeNotification
{
    [NOTIFICATION_CENTER removeObserver:self];
    [[ELClient sharedClient].chatManager removeDelegate:self];
}

#pragma mark - 🛰 🌐 Network Method 🌐

/**
 *  加载数据
 */
- (void)loadData
{
    // 加载会话数据
    @weakify(self);
    [[ELClient sharedClient].chatManager getAllConversations:^(NSArray<ELConversation *> *conversations, NSError *aError) {
        @strongify(self);
        [self.tableView endRefreshing];
        if (!aError) {
            [self.tableView hideDefaultView];
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:conversations];
            if (!self.dataSource.count) {
                [self.tableView showDefaultNoDataView];
            }
            [self.tableView reloadData];
        } else {
            @weakify(self);
            [self.tableView showDefaultErrorViewDidClickHandle:^{
                @strongify(self);
                [self loadData];
            }];
        }
    }];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  某个会话的未读消息清零的通知的回调
 */
- (void)conversationUnreadCountToZero
{
    /// 重新加载数据
    [self loadData];
}

#pragma mark - 📕 👀 UITableViewDataSource 👀

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ELConversationCell";
    ELConversationCell *cell = (ELConversationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ELConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    ELConversation *model = [self.dataSource objectAtIndex:row];
    cell.model = model;
    return cell;
}

#pragma mark - 💉 👀 UITableViewDelegate 👀

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    ELConversation *model = [self.dataSource objectAtIndex:row];
    ELChatViewController *vc = [[ELChatViewController alloc] initWithConversation:model];
    [self.navigationController pushViewController:vc animated:YES];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除会话
        NSInteger row = indexPath.row;
        ELConversation *model = [self.dataSource objectAtIndex:row];
        @weakify(self);
        [[ELClient sharedClient].chatManager removeConversation:model.conversationId completion:^(NSError *aError) {
            @strongify(self);
            if (!aError) {
                [self loadData];
            } else {
                [self.view showText:@"删除失败"];
            }
        }];
    }
}

#pragma mark - 💉 👀 ELChatManagerDelegate 👀

/**
 *  收到消息的回调
 */
- (void)messageDidReceive:(ELMessage *)aMessages
{
    // 重新加载数据
    [self loadData];
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
