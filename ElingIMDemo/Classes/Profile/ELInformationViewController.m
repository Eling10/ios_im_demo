//
//  ELInformationViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELInformationViewController.h"

#import "ElingIM.h"
#import "ELColorMacros.h"

#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>

@interface ELInformationViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UITableViewCell *iconCell;
@property (strong, nonatomic) UITableViewCell *nickNameCell;
@property (strong, nonatomic) UITableViewCell *accountCell;

@end

@implementation ELInformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"个人资料";
    
    // tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorColor = ELCELL_SEPRATOR_COLOR;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.left.bottom.right.equalTo(self.view);
     }];
    
    ELUserInformation *infoM = [ELClient sharedClient].userManager.currentUser;
    self.iconCell = [self _iconCell:infoM.avatarUrl];
    self.nickNameCell = [self _cellWithTitle:@"昵称" subtitle:infoM.nickName];
    self.accountCell = [self _cellWithTitle:@"账号" subtitle:infoM.userName];
    
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:@[self.iconCell, self.nickNameCell, self.accountCell]];
    [self.tableView reloadData];
}

#pragma mark - 🔒 👀 Privite Method 👀

- (UITableViewCell *)_cellWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.text = subtitle;
    cell.detailTextLabel.textColor = ELGRAY_TEXT_COLOR;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (UITableViewCell *)_iconCell:(NSString *)avatarURL
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"iconCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
    // 群头像
    UIView *avatarView = [UIView new];
    avatarView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    UILabel *avatarTitleLB = [UILabel new];
    avatarTitleLB.font = [UIFont systemFontOfSize:16];
    avatarTitleLB.textColor = [UIColor blackColor];
    avatarTitleLB.backgroundColor = [UIColor clearColor];
    avatarTitleLB.text = @"头像";
    [avatarView addSubview:avatarTitleLB];
    [avatarTitleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarView).offset(15);
        make.top.equalTo(avatarView);
        make.bottom.equalTo(avatarView).offset(-10);
    }];
    UIImageView *avatar = [[UIImageView alloc] init];
    [avatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.layer.cornerRadius = 4;
    avatar.layer.masksToBounds = YES;
    [avatarView addSubview:avatar];
    [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_offset(60);
        make.right.equalTo(avatarView).offset(-15);
        make.top.equalTo(avatarView).offset(10);
    }];
    // 分隔线
    UIView *seperator3 = [UIView new];
    seperator3.backgroundColor = self.view.backgroundColor;
    [avatarView addSubview:seperator3];
    [seperator3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(avatarView);
        make.bottom.equalTo(avatarView);
        make.height.offset(10);
    }];
    return cell;
}

#pragma mark - 📕 👀 UITableViewDataSource 👀

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.dataSource[indexPath.row];
}

#pragma mark - 💉 👀 UITableViewDelegate 👀

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) return 90;
    
    return 50;
}

@end
