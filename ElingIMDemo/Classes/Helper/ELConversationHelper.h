//
//  ELConversationHelper.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/22.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <ElingIM/ELConversation.h>

@interface ELConversationHelper : NSObject

/// 从会话模型中获取会话头像
+ (NSString *)avatarFromConversation:(ELConversation *)conversation;
/// 从会话模型中获取会话名称
+ (NSString *)nameFromConversation:(ELConversation *)conversation;

@end
