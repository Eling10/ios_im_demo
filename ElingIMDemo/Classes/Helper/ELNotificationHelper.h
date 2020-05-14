//
//  ELNotificationHelper.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：通知管理类 🐾
 */

#import <Foundation/Foundation.h>
#import "ELNotificationModel.h"


@protocol ELNotificationsDelegate <NSObject>

@optional
/**
 *  通知未读数量发生改变的回调（加好友通知）
 *
 *  @param aUnreadCount 未读数量
 */
- (void)didNotificationsUnreadCountUpdate:(NSInteger)aUnreadCount;
/**
 *  通知状态发生改变的回调（加好友通知）
 */
- (void)didNotificationsUpdate;
@end


@interface ELNotificationHelper : NSObject
/// 消息未读数
@property (nonatomic, readonly) NSInteger unreadCount;
/// 通知数据模型数组
@property (nonatomic, strong) NSMutableArray<ELNotificationModel *> *notificationList;

+ (instancetype)sharedInstance;

/**
 *  初始化用户的通知数据（每次登录成功之后需要调用）
 */
- (void)initializeUserNotifications;

/// 添加代理
- (void)addDelegate:(id<ELNotificationsDelegate>)aDelegate;
/// 移除代理
- (void)removeDelegate:(id<ELNotificationsDelegate>)aDelegate;

/// 将本地未读通知数量标记为已读
- (void)markAllAsRead;

/// 保存最新的 notificationList 到本地
- (void)save;

@end
