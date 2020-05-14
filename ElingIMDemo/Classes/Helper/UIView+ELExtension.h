//
//  UIView+ELExtension.h
//  QHYEmployee
//
//  Created by 樊小聪 on 2018/10/16.
//  Copyright © 2018年 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCProgressHUD/UIView+XCProgressHUD.h>
#import <XCMacros/XCMacros.h>


typedef NS_ENUM(NSInteger, ELDefaultType)
{
    ELDefaultTypeNoData = 0, // 没有数据
    ELDefaultTypeNoNetwork,  // 没有网络
    ELDefaultTypeError  // 服务器异常
};


@interface UIView (ELExtension)

/**
 *  显示成功的HUD
 *
 *  @param text 提示文字
 *  @param completion 完成的回调
 */
- (void)showSuccess:(NSString *)text completion:(void(^)(void))completion;


/**
 *  显示失败的HUD
 *
 *  @param text 提示文字
 *  @param completion 完成的回调
 */
- (void)showFailure:(NSString *)text completion:(void(^)(void))completion;


/**
 *  显示文字的HUD
 *
 *  @param text 提示文字
 *  @param completion 完成的回调
 */
- (void)showText:(NSString *)text completion:(void(^)(void))completion;

/**
 *  隐藏默认视图
 */
- (void)hideDefaultView;

#pragma mark - 👀 无数据 👀 💤

/**
 *  显示无数据的视图（默认与父控件的高度为 0）
 */
- (void)showDefaultNoDataView;

/**
 *  显示无数据的视图
 *
 *  @param positionY    缺省页的Y坐标，相对于父控件
 */
- (void)showDefaultNoDataViewWithPositionY:(CGFloat)positionY;

#pragma mark - 👀 无网络 👀 💤

/**
 *  显示无网络的视图（默认与父控件的高度为 0）
 *
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultNoNetworkViewDidClickHandle:(void(^)(void))didClickHandle;

/**
 *  显示无网络的视图
 *
 *  @param positionY        缺省页的Y坐标，相对于父控件
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultNoNetworkViewWithPositionY:(CGFloat)positionY
                               didClickHandle:(void(^)(void))didClickHandle;

#pragma mark - 👀 服务器异常 👀 💤

/**
 *  显示服务器异常的视图（默认与父控件的高度为 0）
 *
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultErrorViewDidClickHandle:(void(^)(void))didClickHandle;

/**
 *  显示服务器异常的视图
 *
 *  @param positionY        缺省页的Y坐标，相对于父控件
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultErrorViewWithPositionY:(CGFloat)positionY
                           didClickHandle:(void(^)(void))didClickHandle;

#pragma mark - 👀 无网络 & 服务器异常 👀 💤

/**
 *  无网络 & 服务器异常
 *
 *  @param type             默认页面类型
 *  @param didClickHandle   点击底部刷新按钮的回调
 */
- (void)showDefaultViewWithDefaultType:(ELDefaultType)type
                        didClickHandle:(void(^)(void))didClickHandle;


@end
