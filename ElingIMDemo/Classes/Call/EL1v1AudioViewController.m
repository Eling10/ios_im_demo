//
//  EL1v1AudioViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：1v1音频通话控制器 🐾
 */

#import "EL1v1AudioViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EL1v1AudioViewController ()

/// 头像
@property (weak, nonatomic) UIImageView *remoteAvater;

@end

@implementation EL1v1AudioViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    /// 设置头像的视图
    UIImageView *remoteAvatar = [[UIImageView alloc] init];
    remoteAvatar.contentMode = UIViewContentModeScaleAspectFill;
    remoteAvatar.layer.masksToBounds = YES;
    remoteAvatar.layer.cornerRadius = 4;

    self.remoteAvater = remoteAvatar;
    [self.view addSubview:remoteAvatar];
    [remoteAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.sizeOffset(CGSizeMake(60, 60));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.statusLabel.mas_bottom);
    }];
    
    /// 名称
    [self.remoteNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remoteAvater.mas_bottom).offset(15);
        make.centerX.equalTo(self.remoteAvater);
    }];
    
    /// 时长
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remoteNameLabel.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
    }];
    
    /// 麦克风
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
        make.width.height.mas_equalTo(@50);
    }];
    
    /// 动画视图
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(self.view.mas_width).multipliedBy(0.65);
    }];
    
    /// 更新 UI
    [self _refreshUI];
}

#pragma mark - 👀 Setter 👀 💤

- (void)setCallStatus:(ELCallSessionStatus)callStatus
{
    [super setCallStatus:callStatus];
    
    /// 对方已经接通
    if (callStatus == ELCallSessionStatusConnected) {
        [UIView animateWithDuration:0.75 animations:^{
            [self.remoteAvater mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.sizeOffset(CGSizeMake(90, 90));
                make.bottom.equalTo(self.view.mas_centerY).offset(-50);
                make.centerX.equalTo(self.view);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)setCallSession:(ELMessage *)callSession
{
    [super setCallSession:callSession];
    
    [self _refreshUI];
}

#pragma mark - 🔒 👀 Privite Method 👀

- (void)_refreshUI
{
    if (self.callSession.direction == ELMessageDirectionSend) {
        [self.remoteAvater sd_setImageWithURL:[NSURL URLWithString:self.callSession.toAvatar] placeholderImage:[UIImage imageNamed:@"icon_avatar_default"]];
    } else {
        [self.remoteAvater sd_setImageWithURL:[NSURL URLWithString:self.callSession.fromAvatar] placeholderImage:[UIImage imageNamed:@"icon_avatar_default"]];
    }
}

@end
