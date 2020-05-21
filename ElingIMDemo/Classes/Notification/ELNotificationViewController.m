//
//  ELNotificationViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：通知控制器（加好友、加群、退群通知） 🐾
 */

#import "ELNotificationViewController.h"

#import "ELNotificationCell.h"
#import "ELNotificationHelper.h"

#import "ElingIM.h"
#import "ELColorMacros.h"
#import "ELChineseToPinyin.h"
#import "UIView+ELExtension.h"

#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ELNotificationViewController ()<UITableViewDataSource, UITableViewDelegate, ELNotificationsDelegate, EMNotificationCellDelegate>

@property (weak, nonatomic) UITableView *tableView;

@end

@implementation ELNotificationViewController

- (void)dealloc
{
    [[ELNotificationHelper sharedInstance] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    /// 设置 UI
    [self setupUI];
    
    /// 注册通知
    [self registerNotification];
    
    /// 更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshUI];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /// 将所有消息标记为已读
    [[ELNotificationHelper sharedInstance] markAllAsRead];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"申请与通知";
    
    // tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

- (void)refreshUI
{
    [self.tableView hideDefaultView];
    if (![[ELNotificationHelper sharedInstance].notificationList count]) {
        [self.tableView showDefaultNoDataView];
    }
    [self.tableView reloadData];
}

#pragma mark - 👀 注册通知 👀 💤

- (void)registerNotification
{
    [[ELNotificationHelper sharedInstance] addDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[ELNotificationHelper sharedInstance].notificationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ELNotificationModel *model = [[ELNotificationHelper sharedInstance].notificationList objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:@"EMNotificationCell_%@", @(model.status)];
    ELNotificationCell *cell = (ELNotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ELNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    cell.model = model;
    return cell;
}

#pragma mark - 💉 👀 UITableViewDelegate 👀

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ELNotificationHelper sharedInstance].notificationList removeObjectAtIndex:indexPath.row];
        [[ELNotificationHelper sharedInstance] save];
        [self refreshUI];
    }
}


#pragma mark - 💉 👀 ELNotificationCellDelegate 👀

- (void)didNotificationsUpdate
{
    [self refreshUI];
}

#pragma mark - 💉 👀 ELNotificationsDelegate 👀

- (void)agreeNotification:(ELNotificationModel *)aModel
{
    [self.view showHUD];
    @weakify(self);
    void (^block) (NSError *aError) = ^(NSError *aError) {
        @strongify(self);
        [self.view hideHUD];
        if (!aError) {
            aModel.status = ELNotificationModelStatusAgreed;
            // 保存到本地
            [[ELNotificationHelper sharedInstance] save];
            [self.tableView reloadData];
            if (self.acceptActionCallback) {
                self.acceptActionCallback();
            }
        }
    };
    
    // 发起同意的请求
    [[ELClient sharedClient].contactManager approveFriendRequestFromUser:aModel.sender completion:^(NSError *aError) {
        block(aError);
    }];
}

- (void)declineNotification:(ELNotificationModel *)aModel
{
    aModel.status = ELNotificationModelStatusDeclined;
    [[ELNotificationHelper sharedInstance] save];
    [self.tableView reloadData];
}


@end
