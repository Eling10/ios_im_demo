//
//  ELNavigationController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELNavigationController.h"
#import "ELColorMacros.h"

@interface ELNavigationController ()

@end

@implementation ELNavigationController

+ (void)initialize
{
    /// 此处配置导航栏的公用属性
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    /// 导航栏字体颜色
    [navBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName: ELNAV_TITLE_COLOR,
       NSFontAttributeName: [UIFont systemFontOfSize:17]}
     ];
    
    /// 导航栏button字体和图片颜色
    [navBar setTintColor: ELNAV_TITLE_COLOR];
    
    /// 导航栏背景颜色
    [navBar setBarTintColor: ELNAV_BACKGROUND_COLOR];
    
    /// 隐藏导航栏分隔线
    [navBar setShadowImage:[UIImage new]];
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    /// 导航栏设置为不透明
    navBar.translucent = NO;
}

/**
 *  当控制器, 拿到导航控制器(需要是这个子类), 进行压栈时, 都会调用这个方法
 *
 *  @param viewController 要压栈的控制器
 *  @param animated       动画
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back-white"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    } else {
        viewController.navigationItem.leftBarButtonItem = nil;
    }
    [super pushViewController:viewController animated:YES];
}

- (void)back
{
    if (self.didClickLeftItemCallBack) {    // 处理用户自定义的事件
        self.didClickLeftItemCallBack();
        self.didClickLeftItemCallBack = nil;
    } else {    // 执行默认的返回操作
        [self popViewControllerAnimated:YES];
    }
}

@end
