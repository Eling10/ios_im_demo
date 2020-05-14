//
//  UIImageView+GIF.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (GIF)

/**
 *  播放 gif 图片
 *
 *  @param imageNames 图片名数组
 *  @param repeatCount 重复播放次数，0代表无限次
 *  @param duration 一次播放完的时间
 */
- (void)play:(NSArray<NSString *> *)imageNames
repeatCount:(NSInteger)repeatCount
    duration:(NSInteger)duration;

/**
 *  停止播放
 */
- (void)stop;

@end
