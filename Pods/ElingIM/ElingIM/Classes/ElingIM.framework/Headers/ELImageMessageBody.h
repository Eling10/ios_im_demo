//
//  ELImageMessageBody.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：图片消息体 🐾
 */

#import "ELFileMessageBody.h"

@interface ELImageMessageBody : ELFileMessageBody

/*!
 *  缩略图的显示名
 */
@property (nonatomic, copy) NSString *thumbnailDisplayName;
/*!
 *  缩略图的本地路径（该路径是根据原图生成的）
 */
@property (nonatomic, copy) NSString *thumbnailLocalPath;
/*!
 *  缩略图在服务器的路径（该路径是根据原图的服务器地址转化生成）
 */
@property (nonatomic, copy) NSString *thumbnailRemotePath;

/*!
 *  缩略图文件的大小, 以字节为单位
 */
@property (nonatomic) long long thumbnailFileLength;

/*!
 *  图片附件的尺寸
    {
        "width": "100",
        "height": "100"
 *   }
 */
@property (nonatomic, copy) NSDictionary *size;

/*!
 *  缩略图下载状态
 */
@property (nonatomic)ELFileDownloadStatus thumbnailDownloadStatus;

@end
