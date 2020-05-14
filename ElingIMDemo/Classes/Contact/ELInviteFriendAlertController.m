//
//  ELInviteFriendAlertController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELInviteFriendAlertController.h"

#import "ELColorMacros.h"

#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <XCCategory/UITextView+XCExtension.h>

@interface ELInviteFriendAlertController ()

@property (weak, nonatomic) UITextView *textView;

@end

@implementation ELInviteFriendAlertController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - 🛠 👀 Setter Method 👀

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.preferredContentSize = CGSizeMake(SCREEN_WIDTH * 0.8, 300);
    self.view.layer.cornerRadius = 16;
    self.view.layer.masksToBounds = YES;
    
    /// 标题
    UILabel *titleLB = [UILabel new];
    titleLB.text = @"添加好友";
    titleLB.font = [UIFont systemFontOfSize:16];
    titleLB.textColor = ELTEXT_COLOR;
    [self.view addSubview:titleLB];
    [titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(25);
    }];
    
    /// 输入框
    UITextView *textView = [[UITextView alloc] init];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.backgroundColor = ELVIEW_BACKGROUND_COLOR;
    textView.layer.cornerRadius = 5;
    textView.placeholder = @"请输入邀请信息";
    textView.placeholderColor = [UIColor colorWithHexString:@"d2d2d2"];
    self.textView = textView;
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(titleLB.mas_bottom).offset(25);
        make.height.mas_offset(120);
    }];
    
    /// 确定、取消 按钮
    UIView *buttonContainer = [UIView new];
    buttonContainer.backgroundColor = ELCELL_SEPRATOR_COLOR;
    [self.view addSubview:buttonContainer];
    [buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_offset(50);
    }];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:ELTEXT_COLOR forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(clickCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(buttonContainer).offset(0.5);;
        make.left.bottom.equalTo(buttonContainer);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.5);
    }];
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    enterButton.backgroundColor = [UIColor whiteColor];
    [enterButton setTitle:@"确定" forState:UIControlStateNormal];
    [enterButton setTitleColor:ELTEXT_COLOR forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(clickEnterAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:enterButton];
    [enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(buttonContainer).offset(0.5);;
        make.right.bottom.equalTo(buttonContainer);
        make.left.equalTo(cancelButton.mas_right).offset(0.5);
    }];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击取消按钮的回调
 */
- (void)clickCancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  点击确认按钮的回调
 */
- (void)clickEnterAction
{
    if (self.clickEnterButtonCallback) {
        self.clickEnterButtonCallback(self.textView.text);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
