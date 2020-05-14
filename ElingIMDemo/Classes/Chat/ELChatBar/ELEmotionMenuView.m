//
//  ELEmotionMenuView.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import "ELEmotionMenuView.h"
#import "ELChatBarConst.h"
#import <XCMacros/XCMacros.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>

@interface ELEmotionMenuView ()

/// 发送按钮
@property(nonatomic,strong)UIButton *sendButton;

@end

@implementation ELEmotionMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buttonW = 80;
    self.sendButton.frame = CGRectMake(self.width-buttonW, 0, buttonW, self.height);
}

#pragma mark - 🔑 👀 Getter Method 👀

- (UIButton *)sendButton
{
    if (!_sendButton) {
        _sendButton= [UIButton buttonWithType:UIButtonTypeSystem];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_sendButton setBackgroundColor:[UIColor colorWithRed:0.1 green:0.4 blue:0.8 alpha:1.0]];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_sendButton];
        [_sendButton addTarget:self action:@selector(clickSendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击发送按钮的回调
 */
- (void)clickSendButtonAction
{
    /// 发送通知
    [NOTIFICATION_CENTER postNotificationName:ELEmotionDidSendNotification object:nil];
}

@end
