//
//  ELChatBar.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 💉 👀 ELChatBarDelegate 👀

@class ELChatBar;
@protocol ELChatBarDelegate <NSObject>

@optional
/**
 *  语音录制完成的回调
 *
 *  @param bar 聊天栏
 *  @param path 录音文件的路径
 *  @param seconds 录音时长
 */
- (void)chatBar:(ELChatBar *)bar
    audioRecordDidFinish:(NSString *)path
                duration:(NSInteger)seconds;

/**
 *  点击发送按钮的回调
 *
 *  @param bar 聊天栏
 *  @param text 文本（表表会转化为： [大笑]  这种格式）
 */
- (void)chatBar:(ELChatBar *)bar didSend:(NSString *)text;

/**
 *  键盘将升起的回调
 */
- (void)chatBarUp;

@end


@interface ELChatBar : UIView

/// 代理
@property (weak, nonatomic) id<ELChatBarDelegate> delegate;
/// 更多视图
@property (strong, nonatomic, readonly) UIView *moreView;

/**
 *  隐藏键盘
 */
- (void)hideKeyboard;

@end
