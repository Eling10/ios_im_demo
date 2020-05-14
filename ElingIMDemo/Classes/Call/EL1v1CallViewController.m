//
//  EL1v1CallViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：1v1 音视频通话控制器 🐾
 */

#import "EL1v1CallViewController.h"
#import "ELCallHelper.h"

@interface EL1v1CallViewController ()

@property (nonatomic, strong) NSTimer *callDurationTimer;
@property (nonatomic) int callDuration;

@end

@implementation EL1v1CallViewController

- (void)dealloc
{
    [self clearDataAndView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 设置子视图
    [self setupSubViews];
    
    self.timeLabel.hidden = YES;
    self.callStatus = ELCallSessionStatusConnecting;
    [self.waitImgView startAnimating];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.statusLabel.text = @"正在建立连接...";
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:25];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"00:00";
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.remoteNameLabel = [[UILabel alloc] init];
    self.remoteNameLabel.backgroundColor = [UIColor clearColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:15];
    self.remoteNameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.remoteNameLabel];
    [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(15);
        make.left.equalTo(self.statusLabel.mas_left).offset(5);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.waitImgView = [[UIImageView alloc] init];
    self.waitImgView.contentMode = UIViewContentModeScaleAspectFit;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 25; i < 88; i++) {
        NSString *name = [[NSString alloc] initWithFormat:@"animate_000%@", @(i)];
        [array addObject:[UIImage imageNamed:name]];
    }
    [self.waitImgView setAnimationImages:array];
    [self.view addSubview:self.waitImgView];
    [self.waitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
    }];
    
    if (self.callSession.direction == ELMessageDirectionSend) {
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-40);
            make.width.height.equalTo(@60);
        }];
    } else {
        CGFloat size = 60;
        CGFloat padding = ([UIScreen mainScreen].bounds.size.width - size * 2) / 3;
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-40);
            make.right.equalTo(self.view).offset(-padding);
            make.width.height.mas_equalTo(size);
        }];
        
        self.answerButton = [[UIButton alloc] init];
        self.answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.answerButton setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.answerButton];
        [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton);
            make.left.equalTo(self.view).offset(padding);
            make.width.height.mas_equalTo(size);
        }];
    }
    
    // 设置昵称 
    self.remoteNameLabel.text = (self.callSession.direction == ELMessageDirectionSend) ? self.callSession.toName : self.callSession.fromName;
}

- (void)setCallSession:(ELMessage *)callSession
{
    _callSession = callSession;
    
    self.remoteNameLabel.text = (self.callSession.direction == ELMessageDirectionSend) ? self.callSession.toName : self.callSession.fromName;
}

- (void)setCallStatus:(ELCallSessionStatus)callStatus
{
    if (_callStatus == callStatus) {
        return;
    }
    _callStatus = callStatus;
    
    switch (callStatus) {
        case ELCallSessionStatusConnecting: {
            if (self.callSession.direction == ELMessageDirectionSend) {
                self.statusLabel.text = @"正在等待对方接受邀请...";
            } else {
                if (self.callSession.body.type == ELMessageBodyTypeAudioCall) {
                    self.statusLabel.text = @"邀请您语音通话...";
                } else {
                    self.statusLabel.text = @"邀请您视频通话...";
                }
            }
            break;
        }
        case ELCallSessionStatusConnected: {
            [self _startCallDurationTimer];
            self.statusLabel.text = @"通话中...";
            self.timeLabel.hidden = NO;
            self.waitImgView.hidden = YES;
            [self.waitImgView stopAnimating];
            if (self.callSession.direction == ELMessageDirectionReceive) {
                [self.answerButton removeFromSuperview];
                [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view);
                    make.bottom.equalTo(self.view).offset(-40);
                    make.width.height.equalTo(@60);
                }];
            }
            if (self.microphoneButton.isSelected) {
                [[ELClient sharedClient].callManager setAudioEnable:NO];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.microphoneButton.isSelected) {
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    [audioSession setActive:YES error:nil];
                }
            });
            break;
        }
        default:
            break;
    }
}

#pragma mark - Timer

- (void)_updateCallDuration
{
    self.callDuration += 1;
    int hour = self.callDuration / 3600;
    int m = (self.callDuration - hour * 3600) / 60;
    int s = self.callDuration - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%02i:%02i:%02i", hour, m, s];
    } else if(m > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%02i:%02i", m, s];
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"00:%02i", s];
    }
}

#pragma mark - 🎬 👀 Action Method 👀

- (void)microphoneButtonAction
{
    self.microphoneButton.selected = !self.microphoneButton.selected;
    [[ELClient sharedClient].callManager setAudioEnable:!self.microphoneButton.isSelected];
}

- (void)hangupAction
{
    [self clearDataAndView];
    
    NSString *callId = self.callSession.conversationId;
    _callSession = nil;
    
    ELCallEndReason reason;
    if (self.callStatus == ELConnectionStateReconnect) {    // 挂断
        reason = ELCallEndReasonHangup;
    } else {  // 拒绝、取消
        reason = ELCallEndReasonCancel;
    }
    [[ELCallHelper sharedHelper] endCall:callId isCaller:self.callSession.description == ELMessageDirectionSend reason:reason];
}

- (void)answerAction
{   // 同意接听
    [[ELCallHelper sharedHelper] acceptCall:self.callSession.conversationId];
}

#pragma mark - 🔒 👀 Privite Method 👀

- (void)_startCallDurationTimer
{
    [self _stopCallDurationTimer];
    self.callDuration = 0;
    self.callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateCallDuration) userInfo:nil repeats:YES];
}

- (void)_stopCallDurationTimer
{
    if (self.callDurationTimer) {
        [self.callDurationTimer invalidate];
        self.callDurationTimer = nil;
    }
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)clearDataAndView
{
    [self _stopCallDurationTimer];
}

@end
