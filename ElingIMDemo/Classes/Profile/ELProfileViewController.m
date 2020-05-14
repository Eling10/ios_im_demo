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
#import "ELProfileHeaderView.h"

#import "UIView+ELExtension.h"
#import "ELRootViewControllerHelper.h"

#import <ElingIM/ELClient.h>
#import <XCMacros/XCMacros.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>
#import <XCCategory/UIImage+XCExtension.h>

@interface ELProfileViewController ()<UITableViewDelegate>

@property (weak, nonatomic) ELProfileHeaderView *headerView;
@property (weak, nonatomic) UITableView *tableView;

@end

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
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
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
    [logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(25);
        make.right.equalTo(footerView).offset(-25);
        make.height.offset(44);
        make.centerY.equalTo(footerView);
    }];
    
    // tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.rowHeight = 60;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = footerView;
    self.tableView.backgroundColor = [UIColor whiteColor];
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

#pragma mark - 💉 👀 UIScrollViewDelegate 👀

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat downH = scrollView.contentOffset.y;
    if (downH > 0) return;
    _headerBgImgView.height = self.headerView.height - downH;
    _headerBgImgView.top = downH;
}

@end
