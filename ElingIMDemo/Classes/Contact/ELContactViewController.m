//
//  ELContactViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：联系人列表 🐾
 */

#import "ELContactViewController.h"

#import "ELInviteFriendViewController.h"
#import "ELNotificationViewController.h"
#import "ELGroupViewController.h"
#import "ELChatViewController.h"

#import "ELAvatarNameCell.h"

#import "ELUtilMacros.h"
#import "ELColorMacros.h"
#import "ELChineseToPinyin.h"
#import "ELNotificationHelper.h"
#import "UIScrollView+Refresh.h"
#import "UIView+ELExtension.h"

#import <ElingIM/ELClient.h>
#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ELContactViewController ()<UITableViewDataSource, UITableViewDelegate, ELContactManagerDelegate, ELNotificationsDelegate>

@property (weak, nonatomic) UITableView *tableView;
/// 通知的 cell
@property (nonatomic, strong) ELAvatarNameCell *notifCell;
@property (nonatomic, strong) UILabel *notifBadgeLabel;

/// 联系人数据
@property (strong, nonatomic) NSMutableArray *allContacts;
/// 标题文字索引数据
@property (strong, nonatomic) NSMutableArray *sectionTitles;

@end

static NSString *const ELNotificationsCellIdentifier = @"ELNotificationsCellIdentifier";
static NSString *const ELAvatarNameCellIdentifier = @"ELAvatarNameCellIdentifier";

@implementation ELContactViewController

- (void)dealloc
{
    [[ELClient sharedClient].contactManager removeDelegate:self];
    [[ELNotificationHelper sharedInstance] removeDelegate:self];
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

#pragma mark - 💤 👀 LazyLoad Method 👀

LazyLoadMethod(allContacts);
LazyLoadMethod(sectionTitles);

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"联系人";
    
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
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    @weakify(self);
    self.tableView.loadNewDataHandle = ^{
        @strongify(self);
        [self loadData];
    };
    
    /// 好友通知
    self.notifCell = [[ELAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ELNotificationsCellIdentifier];
    self.notifCell.avatarView.image = [UIImage imageNamed:@"notification"];
    self.notifCell.nameLabel.text = @"申请与通知";
    self.notifCell.nameLabel.font = [UIFont systemFontOfSize:18];
    
    self.notifBadgeLabel = [[UILabel alloc] init];
    self.notifBadgeLabel.backgroundColor = [UIColor redColor];
    self.notifBadgeLabel.textColor = [UIColor whiteColor];
    self.notifBadgeLabel.font = [UIFont systemFontOfSize:13];
    self.notifBadgeLabel.hidden = YES;
    self.notifBadgeLabel.clipsToBounds = YES;
    self.notifBadgeLabel.layer.cornerRadius = 10;
    [self.notifCell.contentView addSubview:self.notifBadgeLabel];
    [self.notifBadgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.notifCell.contentView);
        make.right.equalTo(self.notifCell.contentView).offset(-10);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@20);
    }];
}

#pragma mark - 👀 加载数据 👀 💤

- (void)loadData
{
    [self.allContacts removeAllObjects];
    [self.dataSource removeAllObjects];
    
    @weakify(self);
    [[ELClient sharedClient].contactManager getContactsWithCompletion:^(NSArray<ELUserInformation *> *aList, NSError *aError) {
        @strongify(self);
        [self.tableView endRefreshing];
        if (!aError) {
            [self.allContacts addObjectsFromArray:aList];
            [self _sortAllContacts:self.allContacts];
            [self.tableView reloadData];
        } else {
            [self.view showText:aError.localizedDescription];
        }
    }];
}

#pragma mark - 👀 Notification 👀 💤

- (void)registerNotification
{
    /// 联系人管理的通知
    [[ELClient sharedClient].contactManager addDelegate:self];
    
    /// 未读通知数量
    [[ELNotificationHelper sharedInstance] addDelegate:self];
    [self didNotificationsUnreadCountUpdate:[ELNotificationHelper sharedInstance].unreadCount];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  数据排序
 */
- (void)_sortAllContacts:(NSArray *)aContactList
{
    [self.dataSource removeAllObjects];
    [self.sectionTitles removeAllObjects];
    
    NSMutableArray *contactArray = [NSMutableArray arrayWithArray:aContactList];
    
    // 建立索引的核心, 返回27，是a－z和＃
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    // 按首字母分组
    for (ELUserInformation *contact in contactArray) {
        NSString *firstLetter = [ELChineseToPinyin pinyinFromChineseString:contact.nickName];
        NSInteger section;
        if (firstLetter.length > 0) {
            section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        } else {
            section = [sortedArray count] - 1;
        }
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:contact];
    }
    
    // 每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(ELUserInformation *contact1, ELUserInformation *contact2) {
            NSString *firstLetter1 = [ELChineseToPinyin pinyinFromChineseString:contact1.nickName];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            NSString *firstLetter2 = [ELChineseToPinyin pinyinFromChineseString:contact2.nickName];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    // 去掉空的section
    for (NSInteger i = [sortedArray count] - 1; i >= 0; i--) {
        NSArray *array = [sortedArray objectAtIndex:i];
        if ([array count] == 0) {
            [sortedArray removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    [self.dataSource addObjectsFromArray:sortedArray];
}


- (void)_deleteContact:(NSString *)aContact
            completion:(void (^)(void))aCompletion
{
    [[ELClient sharedClient].contactManager deleteContact:aContact completion:^(NSError *aError) {
        if (aError) {
            [self.view showText:@"删除失败"];
        } else {
            aCompletion();
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    return [self.dataSource[section - 1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 1) { // 申请cell特殊化，需要显示角标
        return self.notifCell;
    }
    
    ELAvatarNameCell *cell = (ELAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:ELAvatarNameCellIdentifier];
    if (cell == nil) {
        cell = [[ELAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ELAvatarNameCellIdentifier];
    }

    if (section == 0) {
        if (row == 0) {
            cell.avatarView.image = [UIImage imageNamed:@"contact"];
            cell.nameLabel.text = @"添加好友";
        } else if (row == 2) {
            cell.avatarView.image = [UIImage imageNamed:@"group"];
            cell.nameLabel.text = @"群组";
        } else if (row == 3) {
            cell.avatarView.image = [UIImage imageNamed:@"chatroom"];
            cell.nameLabel.text = @"聊天室";
        }
        cell.nameLabel.font = [UIFont systemFontOfSize:18];
    } else {
        ELUserInformation *infoM = self.dataSource[section - 1][row];
        [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:infoM.avatarUrl] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
        cell.nameLabel.text = infoM.nickName ?: infoM.userName;
        cell.nameLabel.font = [UIFont systemFontOfSize:16];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    ELBaseViewController *vc = nil;
    if (section == 0) {
        if (row == 0) { // 添加好友
            vc = [[ELInviteFriendViewController alloc] init];
        } else if (row == 1) {  // 通知
            vc = [[ELNotificationViewController alloc] init];
            @weakify(self);
            // 同意好友请求后，刷新列表
            ((ELNotificationViewController *)vc).acceptActionCallback = ^{
                @strongify(self);
                [self loadData];
            };
        } else if (row == 2) {  // 群组
            vc = [[ELGroupViewController alloc] init];
        }
    } else {    // 好友聊天
        ELUserInformation *contact = self.dataSource[indexPath.section - 1][indexPath.row];
        vc = [[ELChatViewController alloc] initWithConversationId:contact.userId type:ELChatTypeChat toName:contact.nickName toAvatar:contact.avatarUrl];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.view.backgroundColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 20)];
    label.backgroundColor = self.view.backgroundColor;
    label.textColor = ELGRAY_TEXT_COLOR;
    label.font = [UIFont systemFontOfSize:15];
    
    NSString *title = self.sectionTitles[section - 1];
    label.text = [NSString stringWithFormat:@"  %@", title];
    [view addSubview:label];
    
    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger section = indexPath.section - 1;
        ELUserInformation *contact = self.dataSource[section][indexPath.row];
        [self.view showHUDWithText:@"删除好友..."];
        @weakify(self);
        [self _deleteContact:contact.userId completion:^{
            @strongify(self);
            [self.view showText:@"删除成功" completion:nil];
            NSMutableArray *array = self.dataSource[section];
            [array removeObjectAtIndex:indexPath.row];
            if ([array count] == 0) {
                [self.dataSource removeObjectAtIndex:section];
                [self.sectionTitles removeObjectAtIndex:section];
            }
            [self.tableView reloadData];
            // 发出删除好友的通知
            [NOTIFICATION_CENTER postNotificationName:EL_CONTACT_DELETE_SUCCESS object:nil];
        }];
    }
}

#pragma mark - ELNotificationsDelegate

/// 通知未读数量发生改变
- (void)didNotificationsUnreadCountUpdate:(NSInteger)aUnreadCount
{
    if (aUnreadCount > 0) {
        if (aUnreadCount < 10) {
            self.notifBadgeLabel.textAlignment = NSTextAlignmentCenter;
            self.notifBadgeLabel.text = @(aUnreadCount).stringValue;
        } else {
            self.notifBadgeLabel.textAlignment = NSTextAlignmentLeft;
            self.notifBadgeLabel.text = [NSString stringWithFormat:@" %@ ", @(aUnreadCount)];
        }
        self.notifBadgeLabel.hidden = NO;
    } else {
        self.notifBadgeLabel.hidden = YES;
    }
}

#pragma mark - 💉 👀 ELContactManagerDelegate 👀

/**
 *  对方同意了自己的好友请求
 */
- (void)friendRequestDidApproveByUser:(NSString *)userId
{
    /// 重新加载数据
    [self loadData];
}

@end
