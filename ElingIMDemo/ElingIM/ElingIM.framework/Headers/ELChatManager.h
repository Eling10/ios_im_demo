//
//  ELChatManager.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/13.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：聊天管理类 🐾
 */

#import <Foundation/Foundation.h>
#import "ELMessage.h"
#import "ELConversation.h"
#import "ELGroupManager.h"


/// 进度
// receivedBytes 已经完成的字节数
// expectedBytes 总字节数
typedef void(^ELProgressBlock)(int64_t receivedBytes, int64_t expectedBytes);


@class ELChatManager;
@protocol ELChatManagerDelegate <NSObject>
@optional
/**
 *  收到一条消息，消息会被写入数据库，对于图片、语音、视频、文件类的消息，文件数据会被缓存到本地
 *
 *  @param aMessages 消息
 */
- (void)messageDidReceive:(ELMessage *)aMessages;

/**
 *  会话列表发生变化
 */
- (void)conversationListDidUpdate;

/**
 *  消息状态发生改变的加调（一般是消息附件下载完成后的回调）
 *
 *  @param aMessage 最新的消息
 *  @param aError 错误
 */
- (void)messageStatusDidChange:(ELMessage *)aMessage
                         error:(NSError *)aError;
@end


@interface ELChatManager : NSObject<ELGroupChatDelegate>

- (void)addDelegate:(id<ELChatManagerDelegate>)delegate;
- (void)removeDelegate:(id<ELChatManagerDelegate>)aDelegate;

/**
 *  发送消息，SDK内部会自动上传消息的附件（图片、视频、语音、文件）
 *
 *  @param aMessage 消息实例
 *  @param aCompletionBlock 完成的回调
 */
- (void)sendMessage:(ELMessage *)aMessage
         completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  获取当前用户的所有会话数据，会按照最新的那一条消息进行 降序 排列（聊天室的会话除外）
 */
- (void)getAllConversations:(void(^)(NSArray<ELConversation *> *conversations, NSError *aError))aCompletionBlock;

/**
 *  查询该会话是否是好友会话（只针对单聊）
 *
 *  @param conversationId 会话ID
 */
- (void)getConversationFriendStatus:(NSString *)conversationId
                         completion:(void (^)(BOOL isFriend, NSError *aError))aCompletionBlock;

/**
 *  获取指定会话的消息，如果数据库中不存在，则从服务器中取，按时间顺序 升序 排列（服务器中的数据会同步到本地数据库）
 *
 *  @param conversationId 会话ID
 *  @param page 第几页（从 1 开始）
 *  @param size 每页显示的条数
 */
- (void)getMessages:(NSString *)conversationId
               page:(NSInteger)page
               size:(NSInteger)size
         completion:(void(^)(NSArray<ELMessage *> *messages, NSError *aError))aCompletionBlock;

/**
 *  删除某一条会话（同时会清空该会话中的所有消息记录），数据将会从服务器和本地数据库中移除
 *
 *  @param conversationId 会话ID
 *  @param aCompletionBlock 完成的回调（回调结果以本地数据库的操作结果为准）
 */
- (void)removeConversation:(NSString *)conversationId
                completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  删除某一条会话下的所有消息（会话记录不会被删除），数据将会从服务器和本地数据库中移除
 *
 *  @param conversationId 会话ID
 *  @param aCompletionBlock 完成的回调（回调结果以本地数据库的操作结果为准）
 */
- (void)removeMessages:(NSString *)conversationId
            completion:(void (^)(NSError *aError))aCompletionBlock;


/**
 *  删除某一条消息记录，数据将会从服务器和本地数据库中移除
 *
 *  @param messageId 消息ID
 *  @param aCompletionBlock 完成的回调（回调结果以本地数据库的操作结果为准）
 */
- (void)removeMessage:(NSString *)messageId
           completion:(void (^)(NSError *aError))aCompletionBlock;


/**
 *  将指定会话中的所有消息设置为已读，数据会同步到服务器以及本地数据库
 *
 *  @param conversationId 会话ID
 *  @param aCompletionBlock 完成的回调（回调结果以本地数据库的操作结果为准）
 */
- (void)markAllMessagesAsRead:(NSString *)conversationId
                   completion:(void (^)(NSError *aError))aCompletionBlock;


/**
 *  将某一条消息设置为已读，数据会同步到服务器以及本地数据库
 *
 *  @param messageId 消息ID
 *  @param aCompletionBlock 完成的回调（回调结果以本地数据库的操作结果为准）
*/
- (void)markMessageAsRead:(NSString *)messageId
               completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  返回消息附件缓存目录的路径（如果不存在，会自动创建）
 */
- (NSString *)getMessageAttachmentCachePath;

#pragma mark - 👀 Upload 👀 💤

/**
 *  上传附件到到服务器，上传完成后会同步更新 aMesage 对象
 *
 *  @param aMessage 消息对象
 *  @param progress 进度
 *  @param aCompletionBlock 回调
 */
- (void)uploadMessageAttachment:(ELMessage *)aMessage
                       progress:(ELProgressBlock)progress
                     completion:(void (^)(NSError *error))aCompletionBlock;


#pragma mark - 👀 Download 👀 💤

/**
 *  下载消息附件（语音，视频、文件），下载完成后会同步更新 aMesage 对象
 *
 *  @param aMessage 消息对象
 *  @param progress 进度
 *  @param aCompletionBlock 下载完成的回调
 */
- (void)downloadMessageAttachment:(ELMessage *)aMessage
                         progress:(ELProgressBlock)progress
                       completion:(void (^)(NSError *error))aCompletionBlock;

@end
