//
//  ELConversation.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：会话类，负责管理会话列表相关的数据 🐾
 */

#import <Foundation/Foundation.h>
#import "ELMessage.h"

@interface ELConversation : NSObject

/// 会话ID
//  对于单聊类型，会话ID同时也是对方用户的ID。
//  对于群聊类型，会话ID同时也是对方群组的ID。
//  对于聊天室类型，会话ID同时也是聊天室的ID。
@property (nonatomic, copy) NSString *conversationId;
// 是否是好友
@property (assign, nonatomic) BOOL isFriend;
/// 消息未读数
@property (nonatomic, assign) int unreadMessagesCount;
/// 最新的那一条消息
@property (nonatomic, strong) ELMessage *latestMessage;

@end
