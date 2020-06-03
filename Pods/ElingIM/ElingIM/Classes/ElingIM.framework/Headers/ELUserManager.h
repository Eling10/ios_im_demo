//
//  ELUserManager.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/16.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：用户管理 🐾
 */

#import <Foundation/Foundation.h>
#import "ELUserInformation.h"

/**
 *  验证码类型
 */
typedef NS_ENUM(NSUInteger, ELVerificationCodeType) {
    /// IM修改密码
    ELVerificationCodeTypeUpdatePassword    = 4,
    /// 绑定邮箱
    ELVerificationCodeTypeBindEmail         = 6
};

@interface ELUserManager : NSObject

/// 当前登录用户
@property (strong, nonatomic) ELUserInformation *currentUser;

/// 清空当前登录的用户（缓存的数据会被移除）
- (void)clearCurrentUser;

/**
 *  获取用户信息
 *
 *  @param userId 用户ID
 *  @param aCompletionBlock 回调
 */
- (void)getUserInformation:(NSString *)userId
                completion:(void(^)(NSError *error, ELUserInformation *information))aCompletionBlock;


/**
 *  修改用户信息
 *
 *  @param avatar 头像地址（传 nil 则不做修改）
 *  @param nickName 昵称（传 nil 则不做修改）
 *  @param aCompletionBlock 回调
 */
- (void)updateUserInformationWithAvatar:(NSString *)avatar
                               nickName:(NSString *)nickName
                             completion:(void(^)(NSError *error))aCompletionBlock;

/**
 *  绑定邮箱
 *
 *  @param email 邮箱地址
 *  @param code 邮箱验证码
 *  @param aCompletionBlock 回调
 */
- (void)bindEmail:(NSString *)email
             code:(NSString *)code
       completion:(void(^)(NSError *error))aCompletionBlock;


/**
 *  修改密码
 *
 *  @param newPassword 新密码
 *  @param account 账号
 *  @param code 邮箱验证码
 *  @param aCompletionBlock 回调
 */
- (void)updatePassword:(NSString *)newPassword
               account:(NSString *)account
                  code:(NSString *)code
            completion:(void(^)(NSError *error))aCompletionBlock;


/**
 *  发送邮箱验证码
 *
 *  @param email 邮箱
 *  @param type 验证码类型
 *  @param aCompletionBlock 回调
 */
- (void)sendCodeToEmail:(NSString *)email
                   type:(ELVerificationCodeType)type
             completion:(void(^)(NSError *error))aCompletionBlock;


@end
