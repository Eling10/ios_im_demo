//
//  ELFileMessageBody.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/// class注释 fxcclass
/*
 *  备注：文件消息体 🐾
 */

#import <Foundation/Foundation.h>
#import "ELMessageBody.h"

@interface ELFileMessageBody : ELMessageBody

/*!
 *  \~chinese
 *  附件下载状态
 *
 *  \~english
 *  File downloading status
 */
typedef NS_ENUM(NSUInteger,ELFileDownloadStatus) {
    ELFileDownloadStatusDownloading   = 0,  /*! \~chinese 正在下载 \~english Downloading */
    ELFileDownloadStatusSucceed,            /*! \~chinese 下载成功 \~english Succeed */
    ELFileDownloadStatusFailed             /*! \~chinese 下载失败 \~english Failed */
};

/*!
 *  附件的显示名
 */
@property (nonatomic, copy) NSString *displayName;

/*!
 *  附件的本地路径
 */
@property (nonatomic, copy) NSString *localPath;

/*!
 *  附件在服务器上的路径
 */
@property (nonatomic, copy) NSString *remotePath;

/*!
 *  附件的大小, 以字节为单位
 */
@property (nonatomic) long long fileLength;

/*!
 *  附件的下载状态
 */
@property (nonatomic) ELFileDownloadStatus downloadStatus;

/*!
 *  初始化文件消息体
 *
 *  @param aLocalPath   附件本地路径
 *  @param aDisplayName 附件显示名（不包含路径）
 *
 *  @result 消息体实例
 */
- (instancetype)initWithLocalPath:(NSString *)aLocalPath
                      displayName:(NSString *)aDisplayName;

/*!
 *  初始化文件消息体（数据将会写入本地）
 *
 *  @param aData        附件数据
 *  @param aDisplayName 附件显示名（不包含路径）
 *
 *  @result 消息体实例
 */
- (instancetype)initWithData:(NSData *)aData
                 displayName:(NSString *)aDisplayName;

@end
