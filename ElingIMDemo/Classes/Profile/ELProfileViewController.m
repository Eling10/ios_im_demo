//
//  ELProfileViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：个人中文控制器 🐾
 */

#import "ELProfileViewController.h"
#import "ELInformationViewController.h"
#import "ELProfileHeaderView.h"

#import "ElingIM.h"
#import "ELColorMacros.h"
#import "UIView+ELExtension.h"
#import "ELRootViewControllerHelper.h"

#import <XCMacros/XCMacros.h>
#import <Masonry/Masonry.h>
#import <XCSettingView/XCSettingView.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>
#import <XCCategory/UIImage+XCExtension.h>

@interface ELProfileViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) ELProfileHeaderView *headerView;
@property (weak, nonatomic) UITableView *tableView;

@end


static NSString *const cellIdentifier = @"cellIdentifier";

@implementation ELProfileViewController
{
    // 头部底部的背景视图
    UIImageView *_headerBgImgView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.hideNavigationBar = YES;
    
    // headerView
    ELProfileHeaderView *headerView = [[ELProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.65)];
    self.headerView = headerView;
    [self.headerView.waveView startAnimation];
    // 设置 背景视图 视图
    _headerBgImgView = [[UIImageView alloc] init];
    _headerBgImgView.image = [UIImage imageFromColor:[UIColor colorWithHexString:@"CA4F3A"]];
    _headerBgImgView.contentMode = UIViewContentModeScaleAspectFill;
    _headerBgImgView.layer.masksToBounds = YES;
    _headerBgImgView.frame = self.headerView.bounds;
    [self.headerView insertSubview:_headerBgImgView atIndex:0];
    
    // footerView
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FetchCurrentHeightFromIphone6Height(200))];
    UIView *seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    seperatorLine.backgroundColor = ELCELL_SEPRATOR_COLOR;
    [footerView addSubview:seperatorLine];
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    logoutButton.width = SCREEN_WIDTH - 50;
    logoutButton.height = 44;
    logoutButton.center = footerView.center;
    logoutButton.backgroundColor = [UIColor clearColor];
    [logoutButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont systemFontOfSize:16];
    logoutButton.layer.cornerRadius = 6;
    logoutButton.layer.borderWidth = 1;
    logoutButton.layer.borderColor = [UIColor systemRedColor].CGColor;
    logoutButton.layer.masksToBounds = YES;
    [logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(clickLogoutButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutButton];
    
    // tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = footerView;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.left.bottom.right.equalTo(self.view);
     }];
    
    // 加载数据
    ELUserInformation *infoM = [ELClient sharedClient].userManager.currentUser;
    self.headerView.nickNameLB.text = infoM.nickName;
    [self.headerView.icon sd_setImageWithURL:[NSURL URLWithString:infoM.avatarUrl] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击退出登录的回调
 */
- (void)clickLogoutButtonAction
{
    @weakify(self);
    [[ELClient sharedClient].loginManager logout:^(NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:@"退出失败"];
            return;
        }
        [ELRootViewControllerHelper chooseRootViewControllerWithType:ELRootViewControllerTypeLogin];
    }];
}

#pragma mark - 📕 👀 UITableViewDataSource 👀

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        XCSettingView *settingView = [[XCSettingView alloc] init];
        settingView.title = @"我的资料";
        settingView.showArrowIcon = YES;
        settingView.showLeftIcon = NO;
        [cell.contentView addSubview:settingView];
        [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView);
        }];
    }
    return cell;
}

#pragma mark - 💉 👀 UITableViewDelegate 👀

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /// 跳转到个人信息控制器
    ELInformationViewController *vc = [ELInformationViewController new];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - 💉 👀 UIScrollViewDelegate 👀

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat downH = scrollView.contentOffset.y;
    if (downH > 0) return;
    _headerBgImgView.height = self.headerView.height - downH;
    _headerBgImgView.top = downH;
}

@end
