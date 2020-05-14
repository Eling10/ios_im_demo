//
//  ELEmotionPageView.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
*  备注：表情内容视图（单页） 🐾
*/

#import "ELEmotionPageView.h"
#import "ELChatBarConst.h"
#import "NSString+Emoji.h"
#import <XCMacros/XCMacros.h>
#import <XCCategory/UIView+XCExtension.h>


@interface ELEmotionItem : UIButton

@end

@implementation ELEmotionItem

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectInset(self.bounds, 8, 8);
}

@end


@interface ELEmotionPageView ()

/// 删除按钮
@property(nonatomic, strong)UIButton *deleteButton;

@end


@implementation ELEmotionPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.deleteButton = [ELEmotionItem buttonWithType:UIButtonTypeCustom];
        [self.deleteButton setImage:[UIImage imageNamed:@"[删除]"] forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(clickDeleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat buttonMargin = 10;
    NSUInteger count     = self.emotions.count;
    CGFloat buttonW      = (self.width - 2 * buttonMargin) / ELEmotionMaxColumns;
    CGFloat buttonH      = (self.height - 2 * buttonMargin) / ELEmotionMaxRows;
    for (int i = 0; i < count; i ++) {
        // emotion 按钮
        UIButton *btn = self.subviews[i + 1]; // 因为已经加了一个 deleteButton
        btn.width   = buttonW;
        btn.height  = buttonH;
        btn.left    = buttonMargin + (i % ELEmotionMaxColumns) * buttonW;
        btn.top     = buttonMargin + (i / ELEmotionMaxColumns) * buttonH;
    }
    // 删除按钮
    self.deleteButton.width  = buttonW;
    self.deleteButton.height = buttonH;
    self.deleteButton.left   = buttonMargin + (count % ELEmotionMaxColumns) * buttonW;
    self.deleteButton.top    = buttonMargin + (count / ELEmotionMaxColumns) * buttonH;
}

#pragma mark - 🛠 👀 Setter Method 👀

- (void)setEmotions:(NSArray<ELEmotionModel *> *)emotions
{
    _emotions = emotions;

    @weakify(self);
    [emotions enumerateObjectsUsingBlock:^(ELEmotionModel * _Nonnull emotionM, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        UIButton *button = [ELEmotionItem buttonWithType:UIButtonTypeCustom];
        button.adjustsImageWhenHighlighted = NO;
        button.titleLabel.font = [UIFont systemFontOfSize:28.0];
        button.tag = idx;
        if (emotionM.name) {
            [button setImage:[UIImage imageNamed:emotionM.name] forState:UIControlStateNormal];
        } else {
            [button setTitle:emotionM.code.emoji forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(clickEmotionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击表情按钮的回调
 */
- (void)clickEmotionAction:(UIButton *)button
{
    // 发送通知
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[ELSelectEmotionKey]  = self.emotions[button.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:ELEmotionDidSelectNotification object:nil userInfo:userInfo];
}

/**
 *  点击删除按钮的回调
 */
- (void)clickDeleteAction
{
    // 发送通知
    [NOTIFICATION_CENTER postNotificationName:ELEmotionDidDeleteNotification object:nil userInfo:nil];
}

@end
