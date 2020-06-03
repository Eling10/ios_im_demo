//
//  ELLoginViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：登录控制器 🐾
 */

#import "ELLoginViewController.h"

#import "ElingIM.h"
#import "UIView+ELExtension.h"
#import "ELNotificationHelper.h"
#import "ELRootViewControllerHelper.h"

#import <XCMacros/XCMacros.h>
#import <XCBaseModule/XCUserInformationTool.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#define kDelayRatio     0.2

@interface ELLoginViewController ()

/** 👀 LOGO 图标底部背景视图与输入框视图的距离的约束 👀 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoBgViewBottomToInputConstraint;
/** 👀 LOGO 底部背景视图 👀 */
@property (weak, nonatomic) IBOutlet UIView *logoBgView;
/** 👀 表单底部的容器视图 👀 */
@property (weak, nonatomic) IBOutlet UIView *inputsContainerView;

/// 背景视图
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
/// Logo视图
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
/** 👀 账号输入框底部的背景视图 👀 */
@property (weak, nonatomic) IBOutlet UIView *accountFBgView;
/** 👀 密码输入框底部的背景视图 👀 */
@property (weak, nonatomic) IBOutlet UIView *passwordFBgView;
/** 👀 手机号输入框 👀 */
@property (weak, nonatomic) IBOutlet UITextField *phoneF;
/** 👀 密码输入框 👀 */
@property (weak, nonatomic) IBOutlet UITextField *passwordF;
/// 登录按钮
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
/// 控制密码显示/隐藏的按钮
@property (weak, nonatomic) IBOutlet UIButton *entryButton;

@end

@implementation ELLoginViewController

#pragma mark - ⏳ 👀 LifeCycle Method 👀

- (void)dealloc
{
    /// 移除通知
    [self removeNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
    
    /// 注册通知
    [self registerNotification];
    
    /// 出现
    [self show];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

/**
 *  设置 UI
 */
- (void)setupUI
{
    /// 设置样式
    self.logoBgViewBottomToInputConstraint.constant = FetchCurrentHeightFromIphone6Height(80);
    self.logoBgView.layer.anchorPoint = CGPointMake(0.5, 0);
    self.phoneF.text = [XCUserInformationTool shareInstance].userAccount;
    
    /// 添加点击事件
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewAction)]];
}

/**
 *  注册通知
 */
- (void)registerNotification
{
    /*⏰ ----- 监听键盘的通知 ----- ⏰*/
    
    [NOTIFICATION_CENTER addObserver:self
                            selector:@selector(keyboardWillShow:)
                                name:UIKeyboardWillShowNotification
                              object:nil];
    
    [NOTIFICATION_CENTER addObserver:self
                            selector:@selector(keyboardWillHide:)
                                name:UIKeyboardWillHideNotification
                              object:nil];
}

/**
 *  移除通知
 */
- (void)removeNotification
{
    /*⏰ ----- 移除键盘的通知 ----- ⏰*/
    [NOTIFICATION_CENTER removeObserver:self
                                   name:UIKeyboardWillShowNotification
                                 object:nil];
    
    [NOTIFICATION_CENTER removeObserver:self
                                   name:UIKeyboardWillHideNotification
                                 object:nil];
}

#pragma mark - 🛰 🌐 Network Method 🌐

/**
 *  发送登录的网络请求
 */
- (void)sendLoginRequest
{
    @weakify(self);
    [self.view showHUD];
    [[ELClient sharedClient].loginManager loginWithUsername:self.phoneF.text password:self.passwordF.text completion:^(NSString *userId, NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:aError.localizedDescription completion:nil];
        } else {
            // 登录成功，缓存登录状态
            [XCUserInformationTool shareInstance].userAccount  = self.phoneF.text;
            [XCUserInformationTool shareInstance].userPassword = self.passwordF.text;
            [XCUserInformationTool shareInstance].login = YES;
            // 初始化用户相关的通知数据
            [[ELNotificationHelper sharedInstance] initializeUserNotifications];
            [self.view showText:@"登录成功" completion:^{
                [ELRootViewControllerHelper chooseRootViewControllerWithType:ELRootViewControllerTypeHome];
            }];
        }
    }];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击 view 结束编辑
 */
- (void)clickViewAction
{
    // 点击 view 结束编辑
    [self.inputsContainerView endEditing:YES];
}

/**
 *  点击了眼睛：未选中：密码不可见； 选中：密码可见
 */
- (IBAction)didClickEyeButtonAction:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    self.passwordF.secureTextEntry = !sender.isSelected;
} // 那就好，开心最重要，本来还

/**
 *  点击了登录按钮的回调
 */
- (IBAction)didClickLoginButtonAction:(id)sender
{
    /// 未输入手机号
    if (!self.phoneF.text.length) {
        [self.view showText:@"请输入账号"];
        return;
    }
    
    /// 未输入密码
    if (!self.passwordF.text.length) {
        [self.view showText:@"请输入密码"];
        return;
    }
    
    /// 原密码长度 小于 6 位
    if (self.passwordF.text.length < 6) {
        [self.view showText:@"密码长度不正确"];
        return;
    }
    
    [self.view endEditing:YES];
    
    /// 发送登录的网络请求
    [self sendLoginRequest];
}

#pragma mark - 键盘弹出检测

/**
 *  键盘即将出现
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    
    NSTimeInterval duration = [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    @weakify(self);
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        
        self.inputsContainerView.transform = CGAffineTransformMakeTranslation(0, -60);
        self.logoBgView.transform  = CGAffineTransformMakeScale(0.7, 0.7);
    }];
}

/**
 *  键盘即将消失
 */
- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    
    NSTimeInterval duration = [[keyboardInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    @weakify(self);
    [UIView animateWithDuration:duration animations:^{
        @strongify(self);
        self.inputsContainerView.transform = CGAffineTransformIdentity;
        self.logoBgView.transform  = CGAffineTransformIdentity;
    }];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  出现
 */
- (void)show
{
    /*⏰ ----- 输入框出现的动画 ----- ⏰*/
    [self.inputsContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0);
        CGFloat delay = idx * kDelayRatio + kDelayRatio;
        [UIView animateWithDuration:1.0 delay:delay usingSpringWithDamping:.6f initialSpringVelocity:.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.transform = CGAffineTransformIdentity;
        } completion:NULL];
    }];
    
    
    /** 👀 LOGO出现的动画 👀 */
    self.logoBgView.alpha = 0;
    
    @weakify(self);
    [UIView animateWithDuration:1.5 animations:^{
        @strongify(self);
        self.logoBgView.alpha = 1;
    }];
}

@end
