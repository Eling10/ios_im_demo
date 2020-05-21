//
//  ELAudioRecordView.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import "ELAudioRecordView.h"
#import "ELAudioRecordHelper.h"
#import "UIImageView+GIF.h"
#import "ElingIM.h"
#import <XCMacros/XCMacros.h>

@interface ELAudioRecordView ()

/// 定时器
@property (nonatomic, strong) dispatch_source_t recordTimer;
/// 蒙板
@property (nonatomic, strong) UIView *recordCoverView;
/// 展示
@property (nonatomic, strong) UIImageView *animationView;
/// 录音
@property (nonatomic, strong) ELAudioRecordHelper *recorder;
/// 录制的秒数
@property (nonatomic, assign) NSUInteger recordSeconds;

@end

@implementation ELAudioRecordView

#pragma mark - 🔑 👀 Getter Method 👀

- (dispatch_source_t)recordTimer
{
    if (!_recordTimer) {
        _recordTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_recordTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    }
    return _recordTimer;
}

- (ELAudioRecordHelper *)recorder
{
    if (!_recorder) {
        _recorder = [ELAudioRecordHelper sharedHelper];
    }
    return _recorder;
}

- (UIImageView *)animationView
{
    if (!_animationView) {
        _animationView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120)*0.5, (SCREEN_HEIGHT - 120)*0.5, 120, 120)];
    }
    return _animationView;
}

- (UIView *)recordCoverView
{
    if (!_recordCoverView) {
        _recordCoverView = [[UIView alloc] initWithFrame:SCREEN_RECT];
        _recordCoverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _recordCoverView.userInteractionEnabled = NO;
        [_recordCoverView addSubview:self.animationView];
    }
    return _recordCoverView;
}

#pragma mark - 🔒 👀 Privite Method 👀

- (NSString *)_getAudioPath
{
    NSString *path = [[ELClient sharedClient].chatManager getMessageAttachmentCachePath];
    return [path stringByAppendingFormat:@"/%.0f", [[NSDate date] timeIntervalSince1970] * 1000];;
}

/**
 *  开始录音
 */
- (void)_startRecord
{
    // 开启定时器
    dispatch_source_set_event_handler(self.recordTimer, ^{
        self.recordSeconds ++;
    });
    dispatch_resume(self.recordTimer);
    
    // 蒙板展示
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.recordCoverView];
    // 展示GIF
    [self.animationView play:@[@"audio_record1", @"audio_record2", @"audio_record3"] repeatCount:0 duration:1];
}

/**
 *  清空录音
 */
- (void)_clearRecord
{
    // 蒙板消失
    [UIView animateWithDuration:0.25 animations:^{
        self.recordCoverView.alpha = 0.0001;
    } completion:^(BOOL finished) {
        // 移除
        [self.recordCoverView removeFromSuperview];
        // 关闭定时器
        dispatch_source_cancel(self.recordTimer);
        self.recordTimer = nil;
        self.recordCoverView = nil;
    }];
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)startRecord
{
    // 开始录制
    NSString *recordPath = [self _getAudioPath];
    @weakify(self);
    [self.recorder startRecordWithPath:recordPath completion:^(NSError *error) {
        @strongify(self);
        if (error) {
            // 取消录音
            [self cancelRecord];
        } else {
            // 录音
            [self _startRecord];
        }
    }];
}

- (void)cancelRecord
{
    /// 结束录音并清空数据
    [self.recorder cancelRecord];
    [self _clearRecord];
}

- (void)stopRecord:(void(^)(NSString *path, NSInteger seconds))completion
{
    @weakify(self);
    [self.recorder stopRecordWithCompletion:^(NSString *aPath, NSInteger aTimeLength) {
        @strongify(self);
        if (completion) {
            completion(aPath, aTimeLength);
        }
        // 清空数据
        [self _clearRecord];
    }];
}

- (void)moveOut
{
    // 停止GIF
    [self.animationView stop];
    // 展示固定图
    [self.animationView setImage:[UIImage imageNamed:@"audio_record_cancel"]];
}

- (void)continueRecord
{
    // 播放 GIF
    [self.animationView play:@[@"audio_record1", @"audio_record2", @"audio_record3"] repeatCount:0 duration:1];
}

@end
