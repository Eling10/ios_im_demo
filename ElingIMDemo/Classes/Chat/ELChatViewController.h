//
//  ELChatViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELBaseViewController.h"
#import "ElingIM.h"

@interface ELChatViewController : ELBaseViewController

/**
 *  根据会话模型来创建聊天控制器（从会话页面进入）
 *
 *  @param conversation 会话模型
 */
- (instancetype)initWithConversation:(ELConversation *)conversation;

/**
 *  根据会话ID、会话类型、目标名称、目标头像来创建聊天控制器（从联系人、群列表页面进入）
 *
 *  @param conversationId 会话ID
 *  @param type 会话类型
 *  @param toName 目标名称
 *  @param toAvatar 目标头像
 */
- (instancetype)initWithConversationId:(NSString *)conversationId
                                  type:(ELChatType)type
                                toName:(NSString *)toName
                              toAvatar:(NSString *)toAvatar;

@end
