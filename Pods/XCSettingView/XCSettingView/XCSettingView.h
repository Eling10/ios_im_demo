//
//  CustomSettingCell.h
//  自定义账号输入框
//
//  Created by 樊小聪 on 2016/11/28.
//  Copyright © 2016年 樊小聪. All rights reserved.
//


/*
 *  备注：自定义 类似 设置界面 cell 的 View 🐾
 */


#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface XCSettingView : UIView

/** 👀 左侧图片 👀 */
@property (strong, nonatomic) IBInspectable UIImage *leftImage;

/** 👀 标题 👀 */
@property (copy, nonatomic) IBInspectable NSString *title;

/** 👀 子标题 👀 */
@property (copy, nonatomic) IBInspectable NSString *subTitle;

/** 👀 子标题的占位文字 👀 */
@property (copy, nonatomic) IBInspectable NSString *subPlaceholder;

/** 👀 标题的颜色 👀 */
@property (weak, nonatomic) IBInspectable UIColor *titleColor;

/** 👀 子标题的颜色 👀 */
@property (weak, nonatomic) IBInspectable UIColor *subTitleColor;

/** 👀 是否显示左侧的图片 👀 */
@property (assign, nonatomic) IBInspectable BOOL showLeftIcon;

/** 👀 是否显示右侧 > 图片 👀 */
@property (assign, nonatomic) IBInspectable BOOL showArrowIcon;

/** 👀 是否显示子标题 👀 */
@property (assign, nonatomic) IBInspectable BOOL showSubTitle;

/** 👀 子标题是否左对齐（左：YES；右：NO）默认 左对齐 👀 */
@property (assign, nonatomic) IBInspectable BOOL subTitleAlignLeft;

/** 👀 是否显示小红点：显示在 主标题的右上角 👀 */
@property (assign, nonatomic) BOOL showRedDot;

@end


