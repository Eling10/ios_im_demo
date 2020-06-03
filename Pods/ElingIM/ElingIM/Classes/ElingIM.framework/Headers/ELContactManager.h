//
//  ELContactManager.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：联系人管理类 🐾
 */

#import <Foundation/Foundation.h>
#import "ELUserInformation.h"


/**
 *  好友相关的回调
 */
@class ELContactManager;
@protocol ELContactManagerDelegate <NSObject>

@optional
/**
 *  用户B同意用户A的加好友请求后，用户A会收到这个回调
 *
 *  @param userId 用户B
 */
- (void)friendRequestDidApproveByUser:(NSString *)userId;

/**
 *  用户B申请加A为好友后，用户A会收到这个回调
 *
 *  @param userId 用户B
 *  @param message 消息
 */
- (void)friendRequestDidReceiveFromUser:(NSString *)userId
                                message:(NSString *)message;

/**
 *  用户A解除与用户B的好友关系后，用户B会收到这个回调
 *
 *  @param userId 用户A
 */
- (void)friendDidRemoveByUser:(NSString *)userId;
@end



@interface ELContactManager : NSObject

/// 添加代理
- (void)addDelegate:(id<ELContactManagerDelegate>)aDelegate;
/// 移除代理
- (void)removeDelegate:(id<ELContactManagerDelegate>)aDelegate;
/// 收到同意、申请的消息，SDK内部调用，外部不用关心
- (void)_receiveMessage:(NSDictionary *)json;

/**
 *  获取好友列表
 *
 *  @param aCompletionBlock 完成的回调
 */
- (void)getContactsWithCompletion:(void (^)(NSArray<ELUserInformation *> *aList, NSError *aError))aCompletionBlock;

/**
 *  搜索联系人
 *
 *  @param username 用户名
 *  @param aCompletionBlock 完成的回调
 */
- (void)searchContactWithUsername:(NSString *)username
                       completion:(void (^)(NSArray<ELUserInformation *> *aList, NSError *aError))aCompletionBlock;

/**
 *  添加好友
 *
 *  @param userId 用户ID
 *  @param aMessage 邀请信息
 */
- (void)addContact:(NSString *)userId
           message:(NSString *)aMessage
        completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  删除好友
 *
 *  @param userId 用户ID
 */
- (void)deleteContact:(NSString *)userId
          completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  同意好友申请
 *
 *  @param userId 用户ID
 */
- (void)approveFriendRequestFromUser:(NSString *)userId
                          completion:(void (^)(NSError *aError))aCompletionBlock;

@end
