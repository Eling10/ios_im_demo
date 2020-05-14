//
//  ELChatBarConst.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELChatBarConst : NSObject

/// 匹配表情
extern NSString * const ELEmotionRegex;

/// 每页表情最多显示的行数
extern NSInteger const ELEmotionMaxRows;
/// 每页表情最多显示的列数
extern NSInteger const ELEmotionMaxColumns;
/// 每页最多显示的表情数量。注：此处需要排除 删除 图标，所以数量会 -1
extern NSInteger const ELEmotionPageSize;

/// 选中表情的 key
extern NSString * const ELSelectEmotionKey;
/// 选中某个表情的通知
extern NSString * const ELEmotionDidSelectNotification;
/// 删除某个表情的通知
extern NSString * const ELEmotionDidDeleteNotification;
/// 改善表情的通知
extern NSString * const ELEmotionDidSendNotification;

/// ChatBar的高度
extern CGFloat const ELChatBarHeight;
/// ChatBar输入框默认的高度
extern CGFloat const ELChatBarInputDefaultHeight;
/// 表情键盘的高度
extern CGFloat const ELEmotionKeyboardHeight;
/// CartBar中按钮的宽度
extern CGFloat const ELChatBarButtonWidth;
/// CartBar中按钮的高度
extern CGFloat const ELChatBarButtonHeight;

@end
