//
//  ELGroupDetailViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/30.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：群组详情控制器 🐾
 */

#import "ELGroupDetailViewController.h"

#import "ELNavigationController.h"
#import "ELGroupMemberListViewController.h"
#import "EMInviteGroupMemberViewController.h"

#import "ELGroupMemberCell.h"

#import "ELColorMacros.h"
#import "ELUtilMacros.h"
#import "UIView+ELExtension.h"

#import <ElingIM/ELGroup.h>
#import <ElingIM/ELClient.h>
#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCCategory/UIColor+XCExtension.h>

#define kMaxCount   15

@interface ELGroupDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ELGroupManagerDelegate>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *footerView;
/// 查看更多按钮
@property (weak, nonatomic) UIButton *moreButton;
/// 群名称输入框
@property (weak, nonatomic) UITextField *nameF;
/// 群头像
@property (weak, nonatomic) UIImageView *avatar;
@property (weak, nonatomic) UIImageView *arrowView;
@property (weak, nonatomic) UIButton *exitButton;
@end


static NSString *const cellIdentifier = @"ELGroupMemberCellIdentifier";
static NSString *const footerIdentifier = @"footerIdentifier";

@implementation ELGroupDetailViewController
{
    NSString *_groupId; // 群ID
    ELGroup *_group;    // 群信息
    BOOL _isMaster;     // 标记自己是否是群主
    NSString *_avatarURL;  // 群组头像地址
}

- (instancetype)initWithGroupId:(NSString *)groupId
{
    if (self = [super init]) {
        _groupId = [groupId copy];
    }
    return self;
}

- (void)dealloc
{
    [[ELClient sharedClient].groupManager removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 IM
    [self setupIM];
    
    /// 设置 UI
    [self setupUI];
    
    /// 加载数据
    [self loadData];
}

#pragma mark - 👀 setupIM 👀 💤

- (void)setupIM
{
    [[ELClient sharedClient].groupManager addDelegate:self];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"群组信息";
    
    /// footerView
    UIView *footerView = [[UIView alloc] init];
    self.footerView = footerView;
    footerView.backgroundColor = [UIColor whiteColor];
    // 查看更多群成员
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreButton = moreButton;
    moreButton.backgroundColor = [UIColor whiteColor];
    moreButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [moreButton addTarget:self action:@selector(clickMoreAction) forControlEvents:UIControlEventTouchUpInside];
    [moreButton setTitle:@"查看更多群成员" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor colorWithHexString:@"555555"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"icon-arrow-right"] forState:UIControlStateNormal];
    [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 150, 0, 0)];
    [moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    moreButton.hidden = YES;
    [footerView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(0);
        make.width.offset(200);
        make.top.equalTo(footerView);
        make.centerX.equalTo(footerView);
    }];
    // 分隔线
    UIView *seperator1 = [UIView new];
    seperator1.backgroundColor = self.view.backgroundColor;
    [footerView addSubview:seperator1];
    [seperator1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(footerView);
        make.top.equalTo(moreButton.mas_bottom);
        make.height.offset(10);
    }];
    // 群名称
    UIView *nameView = [UIView new];
    nameView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(footerView);
        make.top.equalTo(seperator1.mas_bottom);
        make.height.offset(50);
    }];
    UILabel *nameTitleLB = [UILabel new];
    nameTitleLB.font = [UIFont systemFontOfSize:16];
    nameTitleLB.textColor = [UIColor blackColor];
    nameTitleLB.backgroundColor = [UIColor clearColor];
    nameTitleLB.text = @"群名称";
    [nameView addSubview:nameTitleLB];
    [nameTitleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameView).offset(15);
        make.width.offset(80);
        make.top.bottom.equalTo(nameView);
    }];
    UITextField *tf = [UITextField new];
    self.nameF = tf;
    self.nameF.enablesReturnKeyAutomatically = YES;
    self.nameF.font = [UIFont systemFontOfSize:16];
    self.nameF.textAlignment = NSTextAlignmentRight;
    self.nameF.placeholder = @"请输入群名称";
    self.nameF.returnKeyType = UIReturnKeyDone;
    [nameView addSubview:self.nameF];
    [self.nameF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameTitleLB.mas_right);
        make.top.bottom.equalTo(nameView);
        make.right.equalTo(nameView).offset(-15);
    }];
    // 分隔线
    UIView *seperator2 = [UIView new];
    seperator2.backgroundColor = self.view.backgroundColor;
    [footerView addSubview:seperator2];
    [seperator2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(footerView);
        make.top.equalTo(nameView.mas_bottom);
        make.height.offset(10);
    }];
    // 群头像
    UIView *avatarView = [UIView new];
    [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatarAction)]];
    avatarView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(footerView);
        make.top.equalTo(seperator2.mas_bottom);
        make.height.offset(90);
    }];
    UILabel *avatarTitleLB = [UILabel new];
    avatarTitleLB.font = [UIFont systemFontOfSize:16];
    avatarTitleLB.textColor = [UIColor blackColor];
    avatarTitleLB.backgroundColor = [UIColor clearColor];
    avatarTitleLB.text = @"群头像";
    [avatarView addSubview:avatarTitleLB];
    [avatarTitleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarView).offset(15);
        make.top.bottom.equalTo(avatarView);
    }];
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-arrow-right"]];
    self.arrowView = arrow;
    arrow.contentMode = UIViewContentModeScaleAspectFit;
    arrow.alpha = 0.5;
    [avatarView addSubview:arrow];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
       make.right.equalTo(avatarView).offset(-15);
       make.centerY.equalTo(avatarView);
    }];
    UIImageView *avatar = [[UIImageView alloc] init];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.layer.cornerRadius = 4;
    avatar.layer.masksToBounds = YES;
    [avatarView addSubview:avatar];
    self.avatar = avatar;
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_offset(60);
        make.right.equalTo(arrow.mas_left).offset(-10);
        make.centerY.equalTo(arrow);
    }];
    // 分隔线
    UIView *seperator3 = [UIView new];
    seperator3.backgroundColor = ELCELL_SEPRATOR_COLOR;
    [footerView addSubview:seperator3];
    [seperator3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(footerView);
        make.top.equalTo(avatarView.mas_bottom);
        make.height.offset(0.7);
    }];
    // 解散、退出群组
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.exitButton = exitButton;
    exitButton.backgroundColor = [UIColor clearColor];
    [exitButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    exitButton.titleLabel.font = [UIFont systemFontOfSize:16];
    exitButton.layer.cornerRadius = 6;
    exitButton.layer.borderWidth = 1;
    exitButton.layer.borderColor = [UIColor systemRedColor].CGColor;
    exitButton.layer.masksToBounds = YES;
    [exitButton addTarget:self action:@selector(clickExitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:exitButton];
    [exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(25);
        make.right.equalTo(footerView).offset(-25);
        make.height.offset(44);
        make.top.equalTo(seperator3.mas_bottom).offset(90);
    }];
    
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLayout setItemSize:CGSizeMake(SCREEN_WIDTH/5, 90)];
    [collectionViewLayout setMinimumInteritemSpacing:0];
    [collectionViewLayout setMinimumLineSpacing:0];
    [collectionViewLayout setSectionInset:UIEdgeInsetsZero];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.alwaysBounceVertical = YES;
    collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [collectionView registerClass:[ELGroupMemberCell class] forCellWithReuseIdentifier:cellIdentifier];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    [self.view addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
}

/**
 *  更新UI
 */
- (void)_refreshUI
{
    // 增加、减少数据模型
    ELUserInformation *addM = [ELUserInformation new];
    addM.avatarUrl = @"zengjia";
    addM.userId = @"add";
    ELUserInformation *subM = [ELUserInformation new];
    subM.avatarUrl = @"jianshao";
    subM.userId = @"sub";
    
    [self.dataSource removeAllObjects];
    NSInteger maxMemberCount = 0;   // 最多显示的成员数
    BOOL showMoreButton = NO;       // 标记是否显示“查看更多”按钮
    if (_isMaster) {   // 当前用户是群主
        [self.exitButton setTitle:@"解散" forState:UIControlStateNormal];
        self.nameF.userInteractionEnabled = YES;
        self.arrowView.hidden = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(clickSavaAction)];
        maxMemberCount = MIN(kMaxCount-2, _group.memberList.count);
        [self.dataSource addObjectsFromArray:[_group.memberList subarrayWithRange:NSMakeRange(0, maxMemberCount)]];
        [self.dataSource addObjectsFromArray:@[addM, subM]];
        showMoreButton = _group.memberList.count > kMaxCount-2;
    } else {    // 不是群主
        [self.exitButton setTitle:@"退出" forState:UIControlStateNormal];
        self.nameF.userInteractionEnabled = NO;
        self.arrowView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        maxMemberCount = MIN(kMaxCount-1, _group.memberList.count);
        [self.dataSource addObjectsFromArray:[_group.memberList subarrayWithRange:NSMakeRange(0, maxMemberCount)]];
        [self.dataSource addObject:addM];
        showMoreButton = _group.memberList.count > kMaxCount-1;
    }
    self.moreButton.hidden = !showMoreButton;
    CGFloat moreButtonH = showMoreButton ? 60 : 15;
    [self.moreButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.offset(moreButtonH);
    }];
    self.nameF.text = _group.groupName;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:_group.groupAvatar] placeholderImage:[UIImage imageNamed:@"group_default"]];
    [self.collectionView reloadData];
}

#pragma mark - 👀 加载数据 👀 💤

- (void)loadData
{
    @weakify(self);
    [[ELClient sharedClient].groupManager getGroupDetailWithId:_groupId completion:^(ELGroup *group, NSError *aError) {
        @strongify(self);
        if (!aError) {
            self->_group = group;
            self->_isMaster = [self->_group.owner isEqualToString:[ELClient sharedClient].userManager.currentUser.userId];
            [self _refreshUI];
        } else {
            [self.view showText:@"加载失败"];
        }
    }];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击保存的回调（修改群组信息）
 */
- (void)clickSavaAction
{
    if (!self.nameF.text.length) {
        [self.view showText:@"群名称不能为空"];
        return;
    }
    
    @weakify(self);
    [[ELClient sharedClient].groupManager updateGroupWithId:_groupId name:self.nameF.text avatar:_avatarURL completion:^(NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:@"修改失败"];
            return;
        }
        [self.view showText:@"修改成功"];
        // 更新成功，发出通知
        self->_group.groupAvatar = self->_avatarURL ?: self->_group.groupAvatar;
        self->_group.groupName = self.nameF.text;
        [NOTIFICATION_CENTER postNotificationName:EL_GROUP_UPDATE_SUCCESS object:self->_group userInfo:nil];
    }];
}

/**
 *  点击查看更多群组成员按钮的回调
 */
- (void)clickMoreAction
{
    ELGroupMemberListViewController *vc = [[ELGroupMemberListViewController alloc] init];
    vc.groupId = _groupId;
    @weakify(self);
    // 群组成员列表发生改变后，刷新数据源
    vc.groupMemberListDidChangeCallback = ^{
        @strongify(self);
        [self loadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  点击群头像的回调
 */
- (void)tapAvatarAction
{
    if (!_isMaster) return;
}

/**
 *  点击退出、解散按钮的回调
 */
- (void)clickExitButtonAction
{
    if (_isMaster) {    // 解散
        [self _destoryGroup];
    } else { // 退出
        [self _exitGroup];
    }
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  增加群成员
 */
- (void)_addMember
{
    EMInviteGroupMemberViewController *vc = [[EMInviteGroupMemberViewController alloc] initWithExcludeArray:_group.memberList];
    @weakify(self);
    vc.doneCompletion = ^(NSArray<ELUserInformation *> *aSelectedArray) {
        @strongify(self);
        // 增加成员
        [[ELClient sharedClient].groupManager addMembers:aSelectedArray toGroup:self->_groupId completion:^(NSError *aError) {
            @strongify(self);
            [self loadData];
        }];
    };
    ELNavigationController *navVc = [[ELNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVc animated:YES completion:nil];
}

/**
 *  减少群成员
 */
- (void)_subMember
{
    // 过滤出群主
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@", [ELClient sharedClient].userManager.currentUser.userId];
    NSArray *masterArr = [_group.memberList filteredArrayUsingPredicate:predicate];
    EMInviteGroupMemberViewController *vc = [[EMInviteGroupMemberViewController alloc] initWithExcludeArray:masterArr];
    vc.memberList = _group.memberList;
    @weakify(self);
    vc.doneCompletion = ^(NSArray<ELUserInformation *> *aSelectedArray) {
        @strongify(self);
        // 减少成员
        [[ELClient sharedClient].groupManager removeMembers:aSelectedArray fromGroup:self->_groupId completion:^(NSError *aError) {
            @strongify(self);
            [self loadData];
        }];
    };
    ELNavigationController *navVc = [[ELNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVc animated:YES completion:nil];
}

/**
 *  退群
 */
- (void)_exitGroup
{
    @weakify(self);
    [[ELClient sharedClient].groupManager leaveGroup:_groupId completion:^(NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:@"退群失败"];
            return;
        }
        // 返回首页，发出通知
        [self.view showText:@"退群成功"];
        [NOTIFICATION_CENTER postNotificationName:EL_GROUP_EXIT_SUCCESS object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

/**
 *  解散群
 */
- (void)_destoryGroup
{
    @weakify(self);
    [[ELClient sharedClient].groupManager destroyGroup:_groupId completion:^(NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:@"解散群失败"];
            return;
        }
        // 返回首页，发出通知
        [self.view showText:@"解散群成功"];
        [NOTIFICATION_CENTER postNotificationName:EL_GROUP_DISSOLUTION_SUCCESS object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

#pragma mark - 📕 👀 UICollectionViewDataSource 👀

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    ELUserInformation *memberM = self.dataSource[indexPath.item];
    if (memberM.userName) {
        cell.model = [self.dataSource objectAtIndex:indexPath.item];
    } else {
        cell.avatar.image = [UIImage imageNamed:memberM.avatarUrl];
        cell.nameLB.text = nil;
    }
    return cell;
}

#pragma mark - 💉 👀 UICollectionViewDelegate 👀

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
        [self.footerView removeFromSuperview];
        [footerView addSubview:self.footerView];
        [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(footerView);
        }];
        return footerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELUserInformation *info = self.dataSource[indexPath.item];
    if ([info.userId isEqualToString:@"add"]) {     // 增加
        [self _addMember];
    } else if ([info.userId isEqualToString:@"sub"]) {  // 减少
        [self _subMember];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(SCREEN_WIDTH, 380);
}

#pragma mark - 💉 👀 ELGroupManagerDelegate 👀

/**
 *  当群被解散的通知（群主不会收到此回调）
 *
 *  @param groupId 群ID
 */
- (void)groupDidDissolution:(NSString *)groupId
{
    // 返回首页
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *  自己被移出群组的通知（自己主动退群的不会收到此回调）
 *
 *  @param aGroupId 群组ID
 */
- (void)userDidDeleteFromGroup:(NSString *)aGroupId
{
    // 返回首页
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
