//
//  EL1v1VideoViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：1v1视频通话控制器 🐾
 */

#import "EL1v1VideoViewController.h"
#import "ELCallButton.h"
#import <Masonry/Masonry.h>


@interface EL1v1VideoViewController ()

@property (strong, nonatomic) UIView *remoteView;
@property (strong, nonatomic) UIView *localView;
@property (strong, nonatomic) ELCallButton *switchCameraButton;

@end

@implementation EL1v1VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    CGFloat color = 51 / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.font = [UIFont systemFontOfSize:15];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:15];
    self.remoteNameLabel.textColor = [UIColor whiteColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:25];
    
    CGFloat width = 80;
    CGFloat height = 80;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - width * 2) / 3;
    
    self.switchCameraButton = [[ELCallButton alloc] initWithTitle:@"切换摄像头" target:self action:@selector(switchCameraButtonAction:)];
    [self.switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
    }];
    
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_white"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchCameraButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [@[self.switchCameraButton, self.microphoneButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
    [self.waitImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(self.view.mas_width).multipliedBy(0.65);
    }];
    
    /// 初始化对方视频显示的区域
    self.remoteView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.remoteView.backgroundColor = [UIColor clearColor];
    self.remoteView.userInteractionEnabled = NO;
    [self.view addSubview:self.remoteView];
    [self.view sendSubviewToBack:self.remoteView];
    [self.remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    /// 初始化自己视频显示的区域（小区域）
    self.localView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.localView.backgroundColor = [UIColor clearColor];
    self.localView.userInteractionEnabled = NO;
    [self.view addSubview:self.localView];
    [self.view bringSubviewToFront:self.localView];
    [self.localView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remoteNameLabel.mas_bottom);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    /// 初始化 callManager 视图
    [[ELClient sharedClient].callManager setupView:self.localView targetView:self.remoteView];
}

#pragma mark - Action

/**
 *  切换摄像头
 */
- (void)switchCameraButtonAction:(ELCallButton *)aButton
{
    aButton.selected = !aButton.selected;
    [[ELClient sharedClient].callManager switchCamera];
}

@end
