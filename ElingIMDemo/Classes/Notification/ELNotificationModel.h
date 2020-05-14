//
//  ELNotificationModel.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  通知状态
 */
typedef NS_ENUM(NSInteger, ELNotificationModelStatus) {
    /// 默认状态
    ELNotificationModelStatusDefault = 0,
    /// 同意
    ELNotificationModelStatusAgreed,
    /// 拒绝
    ELNotificationModelStatusDeclined
};


@interface ELNotificationModel : NSObject<NSCoding>

/// 接收方ID
@property (nonatomic, copy) NSString *receiver;
/// 发送方ID
@property (nonatomic, copy) NSString *sender;
/// 发送方名称（如果名称为空，则显示账号名）
@property (copy, nonatomic) NSString *senderName;
/// 发送方头像
@property (copy, nonatomic) NSString *senderAvatar;
/// 消息内容
@property (nonatomic, copy) NSString *message;
/// 时间（毫秒）
@property (nonatomic, copy) NSString *time;
/// 是否已读
@property (nonatomic, assign) BOOL isRead;
/// 通知状态
@property (nonatomic, assign) ELNotificationModelStatus status;

@end
