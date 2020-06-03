//
//  ELMessageBody.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/10.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  备注：消息体的定义，所有消息体的基类 🐾
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ELMessageBodyType) {
    ELMessageBodyTypeText   = 0,    /*!  文本类型   */
    ELMessageBodyTypeImage,         /*!  图片类型   */
    ELMessageBodyTypeVideo,         /*!  视频类型   */
    ELMessageBodyTypeVoice,         /*!  语音类型   */
    ELMessageBodyTypeFile,          /*!  文件类型   */
    ELMessageBodyTypeAudioCall,     /*!  语音类型   */
    ELMessageBodyTypeVideoCall      /*!  视频类型   */
};

@interface ELMessageBody : NSObject

/// 消息体类型
@property (nonatomic, assign, readonly) ELMessageBodyType type;

@end
