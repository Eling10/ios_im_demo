//
//  ELVideoMessageBody.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：视频消息体类 🐾
 */

#import "ELFileMessageBody.h"

@interface ELVideoMessageBody : ELFileMessageBody

/*!
 *  \~chinese
 *  视频时长, 秒为单位
 */
@property (nonatomic) int duration;

/*!
 *  \~chinese
 *  缩略图的本地路径
 */
@property (nonatomic, copy) NSString *thumbnailLocalPath;

/*!
 *  \~chinese
 *  缩略图在服务器的路径
 */
@property (nonatomic, copy) NSString *thumbnailRemotePath;

/*!
 *  \~chinese
 *  视频缩略图的尺寸
    {
        "width": "100",
        "height": "100"
 *   }
 */
@property (nonatomic, copy) NSDictionary *thumbnailSize;


/*!
 *  缩略图文件的大小, 以字节为单位
 */
@property (nonatomic) long long thumbnailFileLength;

/*!
 *  \~chinese
 *  缩略图下载状态
 */
@property (nonatomic)ELFileDownloadStatus thumbnailDownloadStatus;

@end
