//
//  ELRootViewControllerHelper.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELRootViewControllerHelper.h"

#import "ElingIM.h"
#import "AppDelegate.h"
#import "UIView+ELExtension.h"

#import <XCBaseModule/XCUserInformationTool.h>
#import <XCCategory/UIViewController+XCExtension.h>

@implementation ELRootViewControllerHelper

+ (void)chooseRootViewController
{
    // 没有最新的版本
    if ([XCUserInformationTool shareInstance].isLogin) {  // 登录状态
        [self chooseRootViewControllerWithType:ELRootViewControllerTypeHome];
    } else {    // 非登录状态
        [self chooseRootViewControllerWithType:ELRootViewControllerTypeLogin];
    }
}

+ (void)chooseRootViewControllerWithType:(ELRootViewControllerType)type
{
    UIViewController *vc = nil;
    switch (type) {
        case ELRootViewControllerTypeHome: {
            vc = [NSClassFromString(@"ELTarBarController") new];
            break;
        }
        case ELRootViewControllerTypeLogin: {
            /// 如果是跳转到 登录的控制器，说明此时用户是未登录状态，则需要更新本地的信息
            [XCUserInformationTool shareInstance].login = NO;
            [XCUserInformationTool shareInstance].userPassword = nil;
            vc = [[UIStoryboard storyboardWithName:@"ELLogin" bundle:nil] instantiateInitialViewController];
            break;
        }
    }
    [self chooseRootViewController:vc];
}

#pragma mark - 🔒 👀 Privite Method 👀

+ (void)chooseRootViewController:(UIViewController *)vc
{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view hideHUD];
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isMemberOfClass:[vc class]]) {
        return;
    }
    // 切换根视图控制器
    AppDelegate *app = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    app.window.rootViewController = vc;
    [app.window makeKeyAndVisible];
    [self addTranstionAnimation];
}

+ (void)addTranstionAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:NULL];
}

@end
