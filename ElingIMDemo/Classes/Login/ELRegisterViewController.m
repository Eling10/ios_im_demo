//
//  ELRegisterViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
*  备注：注册控制器 🐾
*/


#import "ELRegisterViewController.h"

#import "UIView+ELExtension.h"
#import <ElingIM/ELClient.h>

@interface ELRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneF;
@property (weak, nonatomic) IBOutlet UITextField *passwordF;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ELRegisterViewController

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
}

#pragma mark - 🛰 🌐 Network Method 🌐

/**
 *  发送注册的网络请求
 */
- (void)sendRegisterRequest
{
    @weakify(self);
    [self.view showHUD];
    [[ELClient sharedClient].loginManager registerWithUsername:self.phoneF.text password:self.passwordF.text completion:^(NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:aError.localizedDescription completion:nil];
        } else {
            @weakify(self);
            [self.view showText:@"注册成功" completion:^{
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
 *  点击 重置按钮 的回调
 */
- (IBAction)didClickRegisterButtonAction:(UIButton *)sender
{
    /// 未输入手机号
    if (!self.phoneF.text.length) {
        [self.navigationController.view showText:@"请输入手机号"];
        return;
    }
    
    if (!self.passwordF.text.length) {
        [self.navigationController.view showText:@"请输入新密码"];
        return;
    }

    [self.view endEditing:YES];
    
    /// 发送网络请求的网络请求
    [self sendRegisterRequest];
}

@end
