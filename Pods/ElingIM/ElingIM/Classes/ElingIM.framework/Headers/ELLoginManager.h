//
//  ELLoginManager.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 樊小聪. All rights reserved.
//


/*
 *  备注：登录管理类 🐾
 */

#import <Foundation/Foundation.h>

/**
 *  连接状态
 */
typedef NS_ENUM(NSUInteger, ELConnectionState) {
    /// 断开连接
    ELConnectionStateDisconnect = 1,
    /// 重新连接
    ELConnectionStateReconnect
};


@class ELLoginManager;
@protocol ELLoginManagerDelegate <NSObject>

@optional
/**
 *  连接状态发生改变的回调
 *
 *  @param state 状态
 */
- (void)connectionStateDidChange:(ELConnectionState)state;

/**
  登录状态失效的回调
 */
- (void)loginStatusDidInvalid;

@end



@interface ELLoginManager : NSObject

/// 添加代理
- (void)addDelegate:(id<ELLoginManagerDelegate>)delegate;
/// 移除代理
- (void)removeDelegate:(id<ELLoginManagerDelegate>)delegate;

/**
 *  用户注册
 *
 *  @param username 用户名
 *  @param password 密码（6~18位，字母+数字组合）
 *  @param aCompletionBlock 完成的回调
 */
- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                  completion:(void (^)(NSError *aError))aCompletionBlock;

/**
 *  用户登录
 *
 *  @param username 用户名
 *  @param password 密码（6~18位，字母+数字组合）
 *  @param aCompletionBlock 完成的回调
 */
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(void (^)(NSString *userId, NSError *aError))aCompletionBlock;

/**
 *  退出登录
 *
 *  @param aCompletionBlock 回调
 */
- (void)logout:(void (^)(NSError *aError))aCompletionBlock;

@end
