//
//  ELCreateGroupViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/30.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：创建群组控制器 🐾
 */


#import "ELCreateGroupViewController.h"

#import "ElingIM.h"
#import "UIView+ELExtension.h"

#import <XCMacros/XCMacros.h>
#import <Masonry/Masonry.h>

@interface ELCreateGroupViewController ()<UITextFieldDelegate>

/// 群名称
@property (weak, nonatomic) UITextField *nameF;

@end

@implementation ELCreateGroupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    /// 导航栏
    self.title = @"创建群组";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(createGroupAction)];
    
    /// 群名称
    UIView *nameView = [UIView new];
    nameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(10);
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
    self.nameF.delegate = self;
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
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击群组头像的回调
 */
- (void)tapAvatarAction
{
    
}

/**
 *  创建群组
 */
- (void)createGroupAction
{
    if (!self.nameF.text.length) {
        [self.view showText:@"请输入群组名称"];
        return;
    }
    
    @weakify(self);
    [self.view showHUD];
    [[ELClient sharedClient].groupManager createGroupWithGroupName:self.nameF.text completion:^(NSError *aError) {
        @strongify(self);
        if (aError) {
            [self.view showText:@"创建群组失败" completion:nil];
            return;
        }
        // 创建成功
        [self.view showText:@"创建群组成功" completion:nil];
        if (self.successCompletion) {
            self.successCompletion();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - 💉 👀 UITextFieldDelegate 👀

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
