//
//  ELCallViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：音视频通话控制器 🐾
 */

#import "ELCallViewController.h"
#import <Masonry/Masonry.h>

@implementation ELCallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self _setupCallControllerSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChanged:)   name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    if (!isHeadphone()) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [audioSession setActive:YES error:nil];
    }
}

#pragma mark - Subviews

- (void)_setupCallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:25];
    self.statusLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(35);
        } else {
            make.top.equalTo(self.view).offset(35);
        }
        make.left.equalTo(self.view).offset(15);
    }];
    
    // 静音按钮
    self.microphoneButton = [[ELCallButton alloc] initWithTitle:@"静音" target:self action:@selector(microphoneButtonAction)];
    [self.microphoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.microphoneButton];
    
    // 挂断按钮
    self.hangupButton = [[UIButton alloc] init];
    self.hangupButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.hangupButton setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
    [self.hangupButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hangupButton];
}

#pragma mark - NSNotification

- (void)handleAudioRouteChanged:(NSNotification *)aNotif
{
    NSDictionary *interuptionDict = aNotif.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 拔出耳机
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            [audioSession setActive:YES error:nil];
            break;
        }
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
    }
}

#pragma mark - Action

- (void)microphoneButtonAction {}

- (void)hangupAction {}

@end
