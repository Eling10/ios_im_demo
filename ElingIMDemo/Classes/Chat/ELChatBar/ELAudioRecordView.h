//
//  ELAudioRecordView.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ELAudioRecordView;
@protocol ELAudioRecordViewDelegate <NSObject>

@end

@interface ELAudioRecordView : UIView

/**
 *  开始录音
 */
- (void)startRecord;

/**
 *  取消录音
 */
- (void)cancelRecord;

/**
 *  结束录音
 */
- (void)stopRecord:(void(^)(NSString *path, NSInteger seconds))completion;

/// 手指移开录音按钮
- (void)moveOut;

/// 继续录制
- (void)continueRecord;

@end
