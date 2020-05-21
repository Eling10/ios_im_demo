//
//  UIView+ELExtension.m
//  QHYEmployee
//
//  Created by 樊小聪 on 2018/10/16.
//  Copyright © 2018年 樊小聪. All rights reserved.
//

#import "UIView+ELExtension.h"
#import "ELColorMacros.h"
#import <XCCategory/UIScrollView+XCExtension.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIButton+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>
#import <XCMacros/XCMacros.h>


#define DEFAULT_NO_DATA_TAG     7777    // 没有数据的视图的tag
#define DEFAULT_NO_NETWORK_TAG  8888    // 没有网络的视图的tag
#define DEFAULT_ERROR_TAG       9999    // 服务器异常的视图的tag

@implementation UIView (ELExtension)

- (void)showSuccess:(NSString *)text completion:(void(^)(void))completion
{
    [self hideHUD];
    [self performSelector:@selector(showSuccess:) withObject:text afterDelay:0.5];
    DispatchAfter(1, ^{
        if (completion) { completion(); }
    });
}

- (void)showFailure:(NSString *)text completion:(void(^)(void))completion
{
    [self hideHUD];
    [self performSelector:@selector(showError:) withObject:text afterDelay:0.5];
    DispatchAfter(1, ^{
        if (completion) { completion(); }
    });
}

- (void)showText:(NSString *)text completion:(void(^)(void))completion
{
    [self hideHUD];
    [self performSelector:@selector(showText:) withObject:text afterDelay:0.5];
    DispatchAfter(1, ^{
        if (completion) { completion(); }
    });
}

/**
 *  隐藏默认视图
 */
- (void)hideDefaultView
{
    if ([self isKindOfClass:[UIScrollView class]])
    {
        ((UIScrollView *)self).scrollEnabled = YES;
    }
    
    UIView *noDataDefaultView     = [self viewWithTag:DEFAULT_NO_DATA_TAG];
    UIView *noNetworkDefaultView  = [self viewWithTag:DEFAULT_NO_NETWORK_TAG];
    UIView *errorDefaultView      = [self viewWithTag:DEFAULT_ERROR_TAG];
    
    if (noDataDefaultView)
    {
        [noDataDefaultView removeFromSuperview];
    }
    
    if (noNetworkDefaultView)
    {
        [noNetworkDefaultView removeFromSuperview];
    }
    
    if (errorDefaultView)
    {
        [errorDefaultView removeFromSuperview];
    }
}

#pragma mark - 👀 无数据 👀 💤

/**
 *  显示无数据的视图（默认与父控件的高度为 0）
 */
- (void)showDefaultNoDataView
{
    [self showDefaultNoDataViewWithPositionY:0];
}

/**
 *  显示无数据的视图
 *
 *  @param positionY    缺省页的Y坐标，相对于父控件
 */
- (void)showDefaultNoDataViewWithPositionY:(CGFloat)positionY
{
    [self showDefaultViewWithDefaultType:ELDefaultTypeNoData
                               positionY:positionY
                          didClickHandle:NULL];
}

#pragma mark - 👀 无网络 👀 💤

/**
 *  显示无网络的视图（默认与父控件的高度为 0）
 *
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultNoNetworkViewDidClickHandle:(void(^)(void))didClickHandle
{
    [self showDefaultNoNetworkViewWithPositionY:0 didClickHandle:didClickHandle];
}

/**
 *  显示无网络的视图
 *
 *  @param positionY        缺省页的Y坐标，相对于父控件
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultNoNetworkViewWithPositionY:(CGFloat)positionY
                               didClickHandle:(void(^)(void))didClickHandle
{
    [self showDefaultViewWithDefaultType:ELDefaultTypeNoNetwork
                               positionY:positionY
                          didClickHandle:didClickHandle];
}

#pragma mark - 👀 服务器异常 👀 💤

/**
 *  显示服务器异常的视图（默认与父控件的高度为 0）
 *
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultErrorViewDidClickHandle:(void(^)(void))didClickHandle
{
    [self showDefaultErrorViewWithPositionY:0 didClickHandle:didClickHandle];
}

/**
 *  显示服务器异常的视图
 *
 *  @param positionY        缺省页的Y坐标，相对于父控件
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultErrorViewWithPositionY:(CGFloat)positionY
                           didClickHandle:(void(^)(void))didClickHandle
{
    [self showDefaultViewWithDefaultType:ELDefaultTypeError
                               positionY:positionY
                          didClickHandle:didClickHandle];
}

#pragma mark - 👀 无网络 & 服务器异常 👀 💤

/**
 *  无网络 & 服务器异常
 *
 *  @param type             默认页面类型
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultViewWithDefaultType:(ELDefaultType)type
                        didClickHandle:(void(^)(void))didClickHandle
{
    [self showDefaultViewWithDefaultType:type
                               positionY:0
                          didClickHandle:didClickHandle];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  显示默认页面
 *
 *  @param type             默认页面的类型
 *  @param positionY        缺省页的Y坐标，相对于父控件
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultViewWithDefaultType:(ELDefaultType)type
                             positionY:(CGFloat)positionY
                        didClickHandle:(void(^)(void))didClickHandle
{
    [self hideDefaultView];
    
    if ([self isKindOfClass:[UIScrollView class]]   &&
        (type != ELDefaultTypeNoData))
    {
        [((UIScrollView *)self) scrollToTopAnimated:NO];
        ((UIScrollView *)self).scrollEnabled = NO;
    }
    
    UIView *placeView = [[UIView alloc] initWithFrame:CGRectMake(0, positionY, self.width, self.height)];
    placeView.backgroundColor = ELVIEW_BACKGROUND_COLOR;
    [self addSubview:placeView];
    
    BOOL hideRefreshButton; // 是否隐藏刷新按钮
    NSString *imgName;      // 图片名称
    NSString *title;        // 标题
    NSString *desc;         // 描述
    
    switch (type)
    {
        case ELDefaultTypeNoData:     // 没有数据
        {
            hideRefreshButton = YES;
            imgName = @"icon_default_no_data";
            title   = @"暂无数据 ~";
            placeView.tag = DEFAULT_NO_DATA_TAG;
            break;
        }
        case ELDefaultTypeNoNetwork:  // 没有网络
        {
            hideRefreshButton = NO;
            imgName = @"icon_default_net_work";
            title   = @"哎呀，网络出错啦！";
            desc    = @"请点击刷新重试，或检查网络是否正常";
            placeView.tag = DEFAULT_NO_NETWORK_TAG;
            break;
        }
        case ELDefaultTypeError:      // 服务器异常
        {
            hideRefreshButton = NO;
            imgName = @"icon_default_error";
            title   = @"服务器异常";
            placeView.tag = DEFAULT_ERROR_TAG;
            break;
        }
    }
    
    /// 图片
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    imgView.contentMode  = UIViewContentModeScaleAspectFit;
    imgView.centerX = self.width * 0.5;
    
    if (IS_IPHONE_4)
    {
        imgView.top = (self.height-positionY) * 0.15;
    }
    else
    {
        imgView.top = (self.height-positionY) * 0.2;
    }
    
    /// 标题
    UILabel *titleLB = [[UILabel alloc] init];
    titleLB.width = self.width;
    titleLB.height = 20;
    titleLB.top = CGRectGetMaxY(imgView.frame) + 15;
    titleLB.left = 0;
    titleLB.textAlignment = NSTextAlignmentCenter;
    titleLB.textColor = [UIColor colorWithHexString:@"AFAFAF"];
    titleLB.font = [UIFont systemFontOfSize:18];
    titleLB.text = title;
    
    /// 描述
    UILabel *descLB = [[UILabel alloc] init];
    descLB.width = self.width;
    descLB.height = 15;
    descLB.top  = titleLB.bottom + 5;
    descLB.left = 0;
    descLB.textAlignment = NSTextAlignmentCenter;
    descLB.textColor = ELGRAY_TEXT_COLOR;
    descLB.font = [UIFont systemFontOfSize:13];
    descLB.text = desc;
    
    /// 刷新按钮
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    refreshBtn.clickHandle = ^(UIButton *btn){
        
        if (didClickHandle)
        {
            didClickHandle();
        }
    };
    
    refreshBtn.size    = CGSizeMake(120, 40);
    refreshBtn.centerX = self.width/2;
    refreshBtn.top     = descLB.bottom + 50;
    
    [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [refreshBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    refreshBtn.backgroundColor     = [UIColor colorWithHexString:@"00B5F3"];
    refreshBtn.titleLabel.font     = [UIFont systemFontOfSize:15];
    refreshBtn.layer.cornerRadius  = refreshBtn.height * 0.5;
    refreshBtn.layer.masksToBounds = YES;
    refreshBtn.hidden = hideRefreshButton;
    
    [placeView addSubview:imgView];
    [placeView addSubview:titleLB];
    [placeView addSubview:descLB];
    [placeView addSubview:refreshBtn];
}

@end
