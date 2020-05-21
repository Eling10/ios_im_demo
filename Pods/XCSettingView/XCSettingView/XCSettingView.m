//
//  CustomSettingCell.m
//  自定义账号输入框
//
//  Created by 樊小聪 on 2016/11/28.
//  Copyright © 2016年 樊小聪. All rights reserved.
//


/*
 *  备注：自定义 类似 设置界面 cell 的 View 🐾
 */



/*⏰ ----- 此处设置一些默认的配置 ----- ⏰*/


#define K_LEFT_ICON_WH          20      // 左侧图标的宽高



#import "XCSettingView.h"


@interface XCSettingView ()

/** 👀 内容视图 👀 */
@property (strong, nonatomic) IBOutlet UIView *contentView;
/** 👀 左侧图标视图 👀 */
@property (weak, nonatomic) IBOutlet UIImageView *leftIcon;
/** 👀 标题LB 👀 */
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
/** 👀 子标题TextField 👀 */
@property (weak, nonatomic) IBOutlet UITextField *subTitleF;
/** 👀 小红点视图 👀 */
@property (weak, nonatomic) IBOutlet UIImageView *redDotView;
/** 👀 右侧箭头图标 👀 */
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;

/** 👀 标题LB的左侧 与 父控件的距离的约束 👀 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLBLeftToSuperConstraint;
/** 👀 左侧图片宽度的约束 👀 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftIconWidthConstraint;
/** 👀 左侧图片高度的约束 👀 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftIconHeightConstraint;
/** 👀 右侧箭头图标右边距离父视图距离的约束 👀 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowIconRightToSuperConstraint;

@end


@implementation XCSettingView

#pragma mark - 👀 Init Method 👀 💤

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // 设置默认参数
        [self setupDefaults];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置默认参数
        [self setupDefaults];
    }
    
    return self;
}

// 设置默认参数
- (void)setupDefaults
{
    UIView *contentView = [[[NSBundle bundleForClass:[XCSettingView class]] loadNibNamed:@"XCSettingView" owner:self options:nil] lastObject];
    self.contentView    = contentView;
    [self addSubview:contentView];
    
    self.leftIconWidthConstraint.constant  = K_LEFT_ICON_WH;
    self.leftIconHeightConstraint.constant = K_LEFT_ICON_WH;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
}

#pragma mark - 👀 Setter Method 👀 💤

- (void)setLeftImage:(UIImage *)leftImage
{
    _leftImage = leftImage;
    
    self.leftIcon.image = leftImage;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    
    self.titleLB.text = title;
}

- (void)setSubTitle:(NSString *)subTitle
{
    _subTitle = [subTitle copy];
    
    self.subTitleF.text = subTitle;
}

- (void)setSubPlaceholder:(NSString *)subPlaceholder
{
    _subPlaceholder = [subPlaceholder copy];
    
    self.subTitleF.placeholder = subPlaceholder;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    self.titleLB.textColor = titleColor;
}

- (void)setSubTitleColor:(UIColor *)subTitleColor
{
    _subTitleColor = subTitleColor;
    
    self.subTitleF.textColor = subTitleColor;
}

- (void)setShowLeftIcon:(BOOL)showLeftIcon
{
    _showLeftIcon = showLeftIcon;
    
    if (showLeftIcon) {
        // 显示左侧的图片
        self.titleLBLeftToSuperConstraint.constant = 30 + K_LEFT_ICON_WH;
        self.leftIcon.hidden = NO;
    } else {
        // 隐藏左侧的图片
        self.titleLBLeftToSuperConstraint.constant = 15;
        self.leftIcon.hidden = YES;
    }
}

- (void)setShowArrowIcon:(BOOL)showArrowIcon
{
    _showArrowIcon = showArrowIcon;
    
    if (showArrowIcon) {
        self.arrowIcon.hidden = NO;
        self.arrowIconRightToSuperConstraint.constant = 35;
    } else {
        self.arrowIcon.hidden = YES;
        self.arrowIconRightToSuperConstraint.constant = 15;
    }
}

- (void)setShowSubTitle:(BOOL)showSubTitle
{
    _showSubTitle = showSubTitle;
    
    self.subTitleF.hidden = !showSubTitle;
}

- (void)setShowRedDot:(BOOL)showRedDot
{
    _showRedDot = showRedDot;
    
    self.redDotView.hidden = !showRedDot;
}

- (void)setSubTitleAlignLeft:(BOOL)subTitleAlignLeft
{
    _subTitleAlignLeft = subTitleAlignLeft;
    
    self.subTitleF.textAlignment = subTitleAlignLeft ? NSTextAlignmentLeft : NSTextAlignmentRight;
}

@end

