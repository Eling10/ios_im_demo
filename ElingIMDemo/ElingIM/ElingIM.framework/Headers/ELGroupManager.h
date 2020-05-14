//
//  ELGroupManager.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：群组操作管理类 🐾
 */

#import <Foundation/Foundation.h>
#import "ELGroup.h"
#import "ELUserInformation.h"

/**
 *  群聊代理（此代理由 SDK 内部调用，外部不用关心）
 */
@protocol ELGroupChatDelegate <NSObject>
@required
/**
 收到群组消息

 @param aMessage 消息
 @param fromID 消息来源
 @param groupID 群组id
 */
- (void)groupMessagesDidReceive:(NSString *)aMessage fromID:(NSString *)fromID groupID:(NSString *)groupID;
@end


/**
 *  群组管理代理
 */
@protocol ELGroupManagerDelegate <NSObject>
@optional
/**
 *  当群被解散的通知（群主不会收到此回调）
 *
 *  @param groupId 群ID
 */
- (void)groupDidDissolution:(NSString *)groupId;

/**
 *  自己被移出群组的通知（自己主动退群的不会收到此回调）
 *
 *  @param aGroupId 群组ID
 */
- (void)userDidDeleteFromGroup:(NSString *)aGroupId;

/**
 *  用户主动退群的通知（只有群主会收到此回调）
 *
 *  @param aGroupId 群组ID
*/
- (void)userDidLeaveFromGroup:(NSString *)aGroupId;

@end


@interface ELGroupManager : NSObject

/// 添加群管理代理
- (void)addDelegate:(id<ELGroupManagerDelegate>)delegate;
/// 移除群管理代理
- (void)removeDelegate:(id<ELGroupManagerDelegate>)delegate;
/// 添加群聊代理（SDK内部调用，群消息转发，外部不用添加）
- (void)_addGroupChatDelegate:(id<ELGroupChatDelegate>)delegate;
/// 群组相关的系统消息（SDK内部调用，外部不用关心）
- (void)_receiveMessage:(NSDictionary *)json;
/**
 发送消息（SDK内部调用）
 
 @param message 消息内容
 @param groupID 群组ID
 @param completion 回调
 */
- (void)_sendMessage:(NSString *)message
             toGroup:(NSString *)groupID
          completion:(void(^)(NSError *error))completion;

/**
 *  获取用户已加入的群组
 *
 *  @param aCompletionBlock 完成的回调
 */
- (void)getGroups:(void (^)(NSArray<ELGroup *> *aList, NSError *aError))aCompletionBlock;

/**
 *  获取群组成员列表（包括当前用户）
 *
 *  @param aGroupId 群组ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)getGroupMemberListWithId:(NSString *)aGroupId
                      completion:(void (^)(NSArray<ELUserInformation *> *aList, NSError *aError))aCompletionBlock;

/**
 *  获取群组详情信息
 *
 *  @param aGroupId 群组ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)getGroupDetailWithId:(NSString *)aGroupId
                  completion:(void (^)(ELGroup *group, NSError *aError))aCompletionBlock;

/**
 *  创建群组
 *
 *  @param groupName 群组名称（最多20位字符长度）
 *  @param aCompletionBlock 完成的回调
 */
- (void)createGroupWithGroupName:(NSString *)groupName
                      completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  修改群信息（群名称、头像），传空则表示不修改此项
 *
 *  @param aGroupId 群组ID
 *  @param aGroupName 群名称
 *  @param aGroupAvatar 群头像
 *  @param aCompletionBlock 完成的回调
 */
- (void)updateGroupWithId:(NSString *)aGroupId
                     name:(NSString *)aGroupName
                   avatar:(NSString *)aGroupAvatar
               completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  添加群组成员
 *
 *  @param aUsers 被邀请的用户名列表
 *  @param aGroupId 群组ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)addMembers:(NSArray<ELUserInformation *> *)aUsers
           toGroup:(NSString *)aGroupId
        completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  将群成员移出群组, 需要owner权限
 *
 *  @param aUsers 要移出群组的用户列表
 *  @param aGroupId 群组ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)removeMembers:(NSArray<ELUserInformation *> *)aUsers
            fromGroup:(NSString *)aGroupId
           completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  解散群组, 需要owner权限（数据库中与本群相关的会话数据会被清除）
 *
 *  @param aGroupId 群组ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)destroyGroup:(NSString *)aGroupId
          completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  退出群组，owner不能退出群，只能解散群（数据库中与本群相关的会话数据会被清除）
 *
 *  @param aGroupId         群组ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)leaveGroup:(NSString *)aGroupId
        completion:(void (^)(NSError *aError))aCompletionBlock;
@end
