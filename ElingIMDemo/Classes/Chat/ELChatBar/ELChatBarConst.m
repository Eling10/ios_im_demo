//
//  ELChatBarConst.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import "ELChatBarConst.h"

@implementation ELChatBarConst

NSString * const ELEmotionRegex = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";

NSInteger const ELEmotionMaxRows = 3;
NSInteger const ELEmotionMaxColumns = 7;
/// 每页最多显示的表情数量。注：此处需要排除 删除 图标，所以数量会 -1
NSInteger const ELEmotionPageSize =  ((ELEmotionMaxRows * ELEmotionMaxColumns) - 1);

NSString * const ELSelectEmotionKey = @"ELSelectEmotionKey";
NSString * const ELEmotionDidSelectNotification = @"ELEmotionDidSelectNotification";
NSString * const ELEmotionDidDeleteNotification = @"ELEmotionDidDeleteNotification";
NSString * const ELEmotionDidSendNotification = @"ELEmotionDidSendNotification";

CGFloat const ELChatBarHeight = 49.f;
CGFloat const ELChatBarInputDefaultHeight = 35.f;
CGFloat const ELEmotionKeyboardHeight = 215.f;
CGFloat const ELChatBarButtonWidth = 38.f;
CGFloat const ELChatBarButtonHeight = ELChatBarButtonWidth;

@end
