//
//  ELCallViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：音视频通话控制器 🐾
 */

#import "ELBaseViewController.h"
#import "ELCallButton.h"
#import <AVFoundation/AVFoundation.h>

/// 是否插入耳机
static bool isHeadphone()
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([desc.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]
            || [desc.portType isEqualToString:AVAudioSessionPortHeadphones]
            || [desc.portType isEqualToString:AVAudioSessionPortBluetoothLE]
            || [desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            return YES;
        }
    }
    return NO;
}


@interface ELCallViewController : ELBaseViewController

/// 状态视图
@property (nonatomic, strong) UILabel *statusLabel;
/// 静音按钮
@property (nonatomic, strong) ELCallButton *microphoneButton;
/// 挂断按钮
@property (nonatomic, strong) UIButton *hangupButton;

/**
 *  点击静音按钮
 */
- (void)microphoneButtonAction;

/**
 *  点击挂断按钮
 */
- (void)hangupAction;

@end
