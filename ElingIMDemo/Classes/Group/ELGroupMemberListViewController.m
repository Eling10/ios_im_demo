//
//  ELGroupMemberListViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/6.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：群组成员列表控制器 🐾
 */

#import "ELGroupMemberListViewController.h"

#import "ELNavigationController.h"
#import "EMInviteGroupMemberViewController.h"

#import "ELGroupMemberCell.h"

#import "ELColorMacros.h"
#import "ELUtilMacros.h"
#import "UIView+ELExtension.h"

#import <ElingIM/ELClient.h>
#import <ElingIM/ELGroup.h>
#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCCategory/UIColor+XCExtension.h>

@interface ELGroupMemberListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) UICollectionView *collectionView;

@end


static NSString *const cellIdentifier = @"ELGroupMemberCellIdentifier";

@implementation ELGroupMemberListViewController
{
    ELGroup *_group;    // 群信息
    BOOL _isMaster;     // 标记自己是否是群主
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
    
    /// 加载数据
    [self loadData];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.title = @"群成员";
    
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
    [self.dataSource addObjectsFromArray:_group.memberList];
    if (_isMaster) {   // 当前用户是群主
        [self.dataSource addObjectsFromArray:@[addM, subM]];
    } else {    // 不是群主
        [self.dataSource addObject:addM];
    }
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
            self->_isMaster = [group.owner isEqualToString:[ELClient sharedClient].userManager.currentUser.userId];
            [self _refreshUI];
        } else {
            [self.view showText:@"加载失败"];
        }
    }];
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
            if (self.groupMemberListDidChangeCallback) {
                self.groupMemberListDidChangeCallback();
            }
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
            if (self.groupMemberListDidChangeCallback) {
                self.groupMemberListDidChangeCallback();
            }
        }];
    };
    ELNavigationController *navVc = [[ELNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVc animated:YES completion:nil];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ELUserInformation *info = self.dataSource[indexPath.item];
    if ([info.userId isEqualToString:@"add"]) {     // 增加
        [self _addMember];
    } else if ([info.userId isEqualToString:@"sub"]) {  // 减少
        [self _subMember];
    }
}

@end
