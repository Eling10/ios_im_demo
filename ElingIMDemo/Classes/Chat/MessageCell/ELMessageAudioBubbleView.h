//
//  ELMessageAudioBubbleView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：语音消息内容视图 🐾
 */

#import "ELMessageBubbleView.h"

@interface ELMessageAudioBubbleView : ELMessageBubbleView

/// 时长标签
@property (nonatomic, strong) UILabel *textLabel;
/// 图片
@property (nonatomic, strong) UIImageView *imgView;

@end
