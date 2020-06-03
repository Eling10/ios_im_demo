//
//  ELVoiceMessageBody.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/9.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：音频消息体类 🐾
 */

#import "ELFileMessageBody.h"

@interface ELVoiceMessageBody : ELFileMessageBody

/*!
 *  语音时长, 秒为单位
 */
@property (nonatomic, assign) int duration;
/// 标记是否正在播放
@property (nonatomic, assign) BOOL isPlaying;

@end
