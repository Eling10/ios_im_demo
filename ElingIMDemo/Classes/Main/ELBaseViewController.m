//
//  ELBaseViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELBaseViewController.h"
#import "ELColorMacros.h"
#import <XCMacros/XCMacros.h>

@interface ELBaseViewController ()

@end

@implementation ELBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置默认参数
    self.pageSize = 15;
    self.page = 1;
    self.view.backgroundColor = ELVIEW_BACKGROUND_COLOR;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (!iOS11_OR_LATER) {
        BeginIgnoreDeprecatedWarning
        self.automaticallyAdjustsScrollViewInsets = false;
        EndIgnoreDeprecatedWarning
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.isHideNavigationBar animated:YES];
    } 
}

/**
 *  设置状态栏的颜色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 💤 👀 LazyLoad Method 👀

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
