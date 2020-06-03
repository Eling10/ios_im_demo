//
//  ELCallMessageBody.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/15.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：实时音视频通话消息体 🐾
 */


#import "ELMessageBody.h"

/**
 *  通话结束原因
 */
typedef NS_ENUM(NSUInteger, ELCallEndReason) {
    /// 接通后挂断（双方都可以）
    ELCallEndReasonHangup   = 0,
    /// 主叫方取消呼叫（被叫方拒绝接收）
    ELCallEndReasonCancel,
    /// 对方线路正忙
    ELCallEndReasonBusy,
    /// 连接失败
    ELCallEndReasonFailed
};


@interface ELCallMessageBody : ELMessageBody

/// 通话时长（单位：秒）
@property (assign, nonatomic) NSInteger duration;
/// 通话结束原因
@property (assign, nonatomic) ELCallEndReason reason;

@end
