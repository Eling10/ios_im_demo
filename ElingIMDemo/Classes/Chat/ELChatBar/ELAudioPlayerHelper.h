//
//  ELAudioPlayerHelper.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
 *  备注：音频播放工具类 🐾
 */

#import <Foundation/Foundation.h>

@interface ELAudioPlayerHelper : NSObject

@property (nonatomic, strong) id model;

+ (instancetype)sharedHelper;

/**
 *  开始播放语音
 *
 *  @param localPath 本地路径
 *  @param aModel 模型
 *  @param aCompleton 完成的回调
 */
- (void)startPlayerWithPath:(NSString *)localPath
                      model:(id)aModel
                 completion:(void(^)(NSError *error))aCompleton;

/**
 *  停止播放
 */
- (void)stopPlayer;

@end
