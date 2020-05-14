//
//  ELAudioRecordHelper.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
 *  备注：录音工具类 🐾
 */

#import <Foundation/Foundation.h>


@interface ELAudioRecordHelper : NSObject

/**
 *  单例
 */
+ (instancetype)sharedHelper;

/**
 *  开始录音
 *
 *  @param aPath 录音文件存放的路径
 *  @param aCompletion 完成的回调
 */
- (void)startRecordWithPath:(NSString *)aPath
                 completion:(void(^)(NSError *error))aCompletion;

/**
 *  结束录音
 *
 *  @param aCompletion 回调
 */
- (void)stopRecordWithCompletion:(void(^)(NSString *aPath, NSInteger aTimeLength))aCompletion;

/**
 *  取消录音
 */
- (void)cancelRecord;

@end
