//
//  ELMessage.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：聊天消息类 🐾
 */

#import <Foundation/Foundation.h>
#import "ELMessageBody.h"

/**
 *  聊天类型
 */
typedef NS_ENUM(NSUInteger, ELChatType) {
    ELChatTypeChat  = 0,    // 单聊
    ELChatTypeGroupChat,    // 群聊
    ELChatTypeChatRoom      // 聊天室
};

/**
 *  消息发送状态
 */
typedef NS_ENUM(NSUInteger, ELMessageStatus) {
    ELMessageStatusPending  = 0,    // 发送未开始
    ELMessageStatusDelivering,      // 正在发送
    ELMessageStatusSucceed,         // 发送成功
    ELMessageStatusFailed           // 发送失败
};

/**
 *  消息发送的方向
 */
typedef NS_ENUM(NSUInteger, ELMessageDirection) {
    ELMessageDirectionSend  = 0,    // 发送的消息
    ELMessageDirectionReceive       // 接收的消息
};


@interface ELMessage : NSObject

/// 会话ID
//  对于单聊类型，会话ID同时也是对方用户的ID。
//  对于群聊类型，会话ID同时也是对方群组的ID。
//  对于聊天室类型，会话ID同时也是聊天室的ID。
@property (nonatomic, copy) NSString *conversationId;

/*!
 *  消息的唯一标识符（消息发送成功后会生成）
 */
@property (nonatomic, copy) NSString *messageId;

/*!
 *  消息的方向（消息发送成功后会生成）
 */
@property (nonatomic) ELMessageDirection direction;

/*!
 *  发送方（消息发送成功后会生成）
 */
@property (nonatomic, copy) NSString *fromId;

/*!
 *  姓名（发送方）
 */
@property (copy, nonatomic) NSString *fromName;

/*!
 *  头像（发送方）
 */
@property (copy, nonatomic) NSString *fromAvatar;

/*!
 *  接收方
 */
@property (nonatomic, copy) NSString *toId;

/*!
 *  姓名（接收方）
 */
@property (copy, nonatomic) NSString *toName;

/*!
 *  头像（接收方）
 */
@property (copy, nonatomic) NSString *toAvatar;

/*!
 *  发送时间（时间戳，毫秒，消息发送成功后会生成）
 */
@property (nonatomic) long long sendTime;

/*!
 *  消息类型
 */
@property (nonatomic) ELChatType chatType;

/*!
 *  消息状态
 */
@property (nonatomic) ELMessageStatus status;

/*!
 *  是否已读
 */
@property (nonatomic) BOOL isRead;

/*!
 *  消息体
 */
@property (nonatomic, strong) ELMessageBody *body;

/*!
 *  \~chinese
 *  消息扩展
 *
 *  Key值类型必须是NSString, Value值类型必须是NSString或者 NSNumber类型的 BOOL, int, unsigned in, long long, double.
 */
@property (nonatomic, copy) NSDictionary *ext;


/**
 *  初始化消息实例
 *
 *  @param conversationId 会话ID（接收方ID）
 *  @param toName 接收方名称
 *  @param toAvatar 接收方头像
 *  @param body 消息体
 *  @param ext 拓展信息
 */
- (instancetype)initWithConversationId:(NSString *)conversationId
                                toName:(NSString *)toName
                              toAvatar:(NSString *)toAvatar
                                  body:(ELMessageBody *)body
                                   ext:(NSDictionary *)ext;

@end
