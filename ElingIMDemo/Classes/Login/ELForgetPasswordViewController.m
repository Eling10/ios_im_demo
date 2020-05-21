//
//  ELForgetPasswordViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/14.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：忘记密码控制器 🐾
 */

#import "ELForgetPasswordViewController.h"

#import "ElingIM.h"
#import "UIView+ELExtension.h"
#import <XCMacros/XCMacros.h>
#import <XCCountdownButton/XCCountdownButton.h>

@interface ELForgetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountF;
@property (weak, nonatomic) IBOutlet UITextField *passwordF;
@property (weak, nonatomic) IBOutlet UITextField *emailF;
@property (weak, nonatomic) IBOutlet UITextField *codeF;
@property (weak, nonatomic) IBOutlet XCCountdownButton *countdownButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ELForgetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.tableFooterView = self.footerView;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    @weakify(self);
    self.countdownButton.didClickHandle = ^(XCCountdownButton *button) {
        @strongify(self);
        /// 点击 获取验证码 按钮的回调
        [self didClickCountdownButtonAction:button];
    };
}

#pragma mark - 🛰 🌐 Network Method 🌐

/**
 *  发送获取邮箱验证码的网络请求
 */
- (void)sendGetCodeRequest
{
    [self.view showHUD];
    @weakify(self);
    [[ELClient sharedClient].userManager sendCodeToEmail:self.emailF.text type:(ELVerificationCodeTypeUpdatePassword) completion:^(NSError *error) {
        if (!error) {
            @strongify(self);
            /// 获取验证码成功
            [self.view hideHUD];
            [self.countdownButton startCounting];
        } else {
            [self.view showText:error.localizedDescription completion:nil];
        }
    }];
}


/**
 *  发送修改密码的网络请求
 */
- (void)sendCommitRequest
{
    [self.view showHUD];
    @weakify(self);
    [[ELClient sharedClient].userManager updatePassword:self.passwordF.text account:self.accountF.text code:self.codeF.text completion:^(NSError *error) {
        @strongify(self);
        if (error) {
            [self.view showText:error.localizedDescription completion:nil];
        } else {
            @weakify(self);
            [self.view showText:@"修改成功" completion:^{
                @strongify(self);
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击 返回按钮的回调
 */
- (IBAction)didClickBackButtonAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  点击了眼睛：未选中：密码不可见； 选中：密码可见
 */
- (IBAction)didClickEyeButtonAction:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    
    self.passwordF.secureTextEntry = !sender.isSelected;
}


/**
 *  点击 获取验证码 按钮的回调
 */
- (void)didClickCountdownButtonAction:(XCCountdownButton *)button
{
    if (!self.emailF.text.length) {
        [self.navigationController.view showText:@"请输入邮箱"];
        return;
    }
    
    /// 发送 获取验证码 的网络请求
    [self sendGetCodeRequest];
}


/**
 *  点击 重置按钮 的回调
 */
- (IBAction)didClickCommitButtonAction:(UIButton *)sender
{
    /// 未输入手机号
    if (!self.accountF.text.length) {
        [self.navigationController.view showText:@"请输入账号"];
        return;
    }
    
    if (!self.codeF.text.length) {
        [self.navigationController.view showText:@"请输入验证码"];
        return;
    }
    
    if (!self.passwordF.text.length) {
        [self.navigationController.view showText:@"请输入新密码"];
        return;
    }

    [self.view endEditing:YES];
    
    /// 发送网络请求的网络请求
    [self sendCommitRequest];
}


@end
