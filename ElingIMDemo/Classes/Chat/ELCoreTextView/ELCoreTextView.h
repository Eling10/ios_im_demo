//
//  ELCoreTextView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCoreTextResultHelper.h"

@class ELCoreTextView;
@protocol ELCoreTextViewDelegate <NSObject>
@optional
/**
 *  点击链接的回调
 *
 *  @param view 视力
 *  @param linkText 链接文字
 *  @param linkType 链接类型
 */
- (void)coreTextView:(ELCoreTextView *)view
    didClickLinkText:(NSString *)linkText
            linkType:(ELCoreTextLinkType)linkType;
@end


@interface ELCoreTextView : UIView

/// 代理
@property (nonatomic, weak) id<ELCoreTextViewDelegate> delegate;
/// 表情尺寸大小 , 默认和字体一致
@property (nonatomic, assign) CGSize emotionSize;
/// 链接点中背景透明度
@property (nonatomic, assign) CGFloat linkedAlpha;
/// 文本
@property (nonatomic, copy) NSString *text;

#pragma mark - 👀 普通文本部分属性 👀 💤
/// 内容字体大小（除开链接特殊字以外内容的字体大小）,默认14.f
@property (nonatomic, strong) UIFont *textFont;
/// 内容字体颜色（除开链接特殊字以外的内容）, 默认黑色
@property (nonatomic, strong) UIColor *textColor;
/// 内容行间距
@property (nonatomic, assign) CGFloat lineSpacing;
/// 字间距
@property (nonatomic, assign) CGFloat wordSpacing;

#pragma mark - 👀 网址链接属性 👀 💤
/// 是否匹配网址链接
@property (nonatomic, assign) BOOL showWebsite;
/// 网址链接字体颜色   默认蓝色
@property (nonatomic, strong) UIColor *websiteColor;
/// 网址链接字体大小 默认14.f
@property (nonatomic, strong) UIFont *websiteFont;
/// 网址链接选中背景色  默认蓝色
@property (nonatomic, strong) UIColor *websiteSelectedBackgroundColor;

#pragma mark - 👀 邮箱链接属性 👀 💤
/// 是否显示邮箱链接
@property (nonatomic, assign) BOOL showEmail;
/// 邮箱链接字体颜色     默认蓝色
@property (nonatomic, strong) UIColor *emailColor;
/// 邮箱链接字体大小     默认14.f
@property (nonatomic, strong) UIFont *emailFont;
/// 邮箱链接选中背景色  默认蓝色
@property (nonatomic, strong) UIColor *emailSelectedBackgroundColor;

#pragma mark - 👀 手机号链接属性 👀 💤
/// 是否显示手机链接
@property (nonatomic, assign) BOOL showMobile;
/// 手机链接字体颜色     默认蓝色
@property (nonatomic, strong) UIColor *mobileColor;
/// 手机链接字体大小     默认14.f
@property (nonatomic, strong) UIFont *mobileFont;
/// 手机链接选中背景色  默认蓝色
@property (nonatomic, strong) UIColor *mobileSelectedBackgroundColor;


+ (instancetype)coreTextView;

@end



