//
//  ELWaveView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELWaveView : UIView

/// 实浪颜色
@property (nonatomic, strong) UIColor *waveColor;
/// 遮罩浪颜色
@property (nonatomic, strong) UIColor *maskWaveColor;

/**
 *  开始动画
 */
- (void)startAnimation;
/**
 *  停止动画
 */
- (void)stopAnimation;

@end
