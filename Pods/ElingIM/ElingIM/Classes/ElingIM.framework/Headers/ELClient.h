//
//  ELClient.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：SDK客户端实例，负责管理SDK的初始化 🐾
 */

#import <Foundation/Foundation.h>
#import "ELChatManager.h"
#import "ELCallManager.h"
#import "ELGroupManager.h"
#import "ELLoginManager.h"
#import "ELUserManager.h"
#import "ELContactManager.h"

/**
 *  阿里云OSS配置项，存储消息中的文件资源
 */
@interface ELOSSOptions : NSObject

/// bucketName，默认：celery-master
@property (copy, nonatomic) NSString *bucketName;
/// endPoint，默认：http://oss-cn-shenzhen.aliyuncs.com/
@property (copy, nonatomic) NSString *endPoint;
/// 服务器上存储文件的一级目录名，默认：starRtc
@property (copy, nonatomic) NSString *directoryName;
/// 文件目录名（二级目录），默认：file
@property (copy, nonatomic) NSString *fileDirectoryName;
/// 图片目录名（二级目录），默认：images
@property (copy, nonatomic) NSString *imageDirectoryName;
/// 语音目录名（二级目录），默认：voice
@property (copy, nonatomic) NSString *voiceDirectoryName;
/// 视频目录名（二级目录），默认：video
@property (copy, nonatomic) NSString *videoDirectoryName;

@end


/**
 *  客户端初始化项目配置类
 */
@interface ELClientOptions : NSObject

/// AppID
@property (copy, nonatomic) NSString *appId;
/// AppSecret
@property (copy, nonatomic) NSString *appSecret;

@end



/**
 *  客户端
 */
@interface ELClient : NSObject

/// 客户端配置项
@property (strong, nonatomic, readonly) ELClientOptions *options;
/// 阿里OSS配置项
@property (strong, nonatomic, readonly) ELOSSOptions *ossOptions;
/// 聊天管理
@property (strong, nonatomic, readonly) ELChatManager *chatManager;
/// 音视频通话管理
@property (strong, nonatomic, readonly) ELCallManager *callManager;
/// 群组管理
@property (strong, nonatomic, readonly) ELGroupManager *groupManager;
/// 登录管理类
@property (strong, nonatomic, readonly) ELLoginManager *loginManager;
/// 用户管理类
@property (strong, nonatomic, readonly) ELUserManager *userManager;
/// 联系人管理类
@property (strong, nonatomic, readonly) ELContactManager *contactManager;

/**
 *  获取 SKD 实例
 */
+ (instancetype)sharedClient;

/**
 *  初始化 SDK，启动App时需要调用此方法
 *
 *  @param options 配置选项
 */
- (void)initializeSDKWithOptions:(ELClientOptions *)options;

@end
