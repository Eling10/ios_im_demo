//
//  ELConversationHelper.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/22.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELConversationHelper.h"

@implementation ELConversationHelper

#pragma mark - 🔓 👀 Public Method 👀

+ (NSString *)avatarFromConversation:(ELConversation *)conversation
{
    ELMessage *message = conversation.latestMessage;
    if (message.chatType == ELChatTypeChat) {   // 单聊
        // 头像
        return (message.direction == ELMessageDirectionSend) ? message.toAvatar : message.fromAvatar;
    }
    // 群聊
    return message.toAvatar;
}

+ (NSString *)nameFromConversation:(ELConversation *)conversation
{
    ELMessage *message = conversation.latestMessage;
    if (message.chatType == ELChatTypeChat) {   // 单聊
        // 名称
        return (message.direction == ELMessageDirectionSend) ? message.toName : message.fromName;
    }
    // 群聊
    return message.toName;
}

#pragma mark - 🔒 👀 Privite Method 👀

@end
