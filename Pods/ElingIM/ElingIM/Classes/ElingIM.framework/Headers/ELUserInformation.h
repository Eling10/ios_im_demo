//
//  ELUserInformation.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：用户信息模型 🐾
 */

#import <Foundation/Foundation.h>

/**
 *  在线状态
 */
typedef NS_ENUM(NSUInteger, ELUserOnlineState) {
    /// 离线
    ELUserOnlineStateOffline    = 0,
    /// 在线
    ELUserOnlineStateOnline,
    /// 免打扰不通知
    ELUserOnlineStateNoDisturb
};

@interface ELUserInformation : NSObject<NSCoding>

/// 所属应用分配的appid
@property (copy, nonatomic) NSString *appid;
/// 头像
@property (copy, nonatomic) NSString *avatarUrl;
/// 昵称
@property (copy, nonatomic) NSString *nickName;
/// 在线状态
@property (assign, nonatomic) ELUserOnlineState onlineState;
/// starRTC对应的用户id
@property (copy, nonatomic) NSString *userId;
/// 用户名
@property (copy, nonatomic) NSString *userName;
/// 密码
@property (copy, nonatomic) NSString *psw;
/// 登录返回的 TOKEN
@property (copy, nonatomic) NSString *token;
/// 是否是好友（查询联系人）
@property (assign, nonatomic) BOOL isFriend;

@end
