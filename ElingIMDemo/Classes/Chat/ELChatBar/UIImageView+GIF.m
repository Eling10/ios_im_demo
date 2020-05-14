//
//  UIImageView+GIF.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import "UIImageView+GIF.h"

@implementation UIImageView (GIF)

- (void)play:(NSArray<NSString *> *)imageNames
 repeatCount:(NSInteger)repeatCount
    duration:(NSInteger)duration
{
    NSMutableArray *arr = [NSMutableArray array];
    [imageNames enumerateObjectsUsingBlock:^(NSString  *_Nonnull imageName, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageNamed:imageName];
        [arr addObject:image];
    }];
    // 设置序列帧图像数组
    self.animationImages = arr;
    // 设置动画时间
    self.animationDuration = duration;
    // 设置播放次数，0代表无限次
    self.animationRepeatCount = repeatCount;
    [self startAnimating];
}

- (void)stop
{
    [self stopAnimating];
}

@end
