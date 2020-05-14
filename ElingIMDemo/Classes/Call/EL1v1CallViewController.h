//
//  EL1v1CallViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：1v1 音视频通话控制器 🐾
 */

#import "ELCallViewController.h"
#import <Masonry/Masonry.h>
#import <ElingIM/ELClient.h>
#import <ElingIM/ELMessage.h>
#import <ElingIM/ELCallMessageBody.h>

typedef NS_ENUM(NSUInteger, ELCallSessionStatus) {
    /// 通话没开始
    ELCallSessionStatusDisconnected = 0,
    /// 通话正在连接
    ELCallSessionStatusConnecting,
    /// 通话接通
    ELCallSessionStatusConnected
};

@interface EL1v1CallViewController : ELCallViewController

/// 对方名称
@property (nonatomic, strong) UILabel *remoteNameLabel;
/// 通话时长
@property (nonatomic, strong) UILabel *timeLabel;
/// 接通按钮
@property (nonatomic, strong) UIButton *answerButton;
/// 等待时的图片
@property (nonatomic, strong) UIImageView *waitImgView;
/// 连接状态
@property (nonatomic) ELCallSessionStatus callStatus;
/// 会话消息
@property (nonatomic, strong) ELMessage *callSession;

/**
 *  清空视图
 */
- (void)clearDataAndView;

@end
