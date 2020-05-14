//
//  ELMessageVideoBubbleView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：视频消息内容视图 🐾
 */

#import "ELMessageImageBubbleView.h"

@interface ELMessageVideoBubbleView : ELMessageImageBubbleView

/// 遮罩视力
@property (nonatomic, strong) UIView *shadowView;
/// 播放图标
@property (nonatomic, strong) UIImageView *playImgView;

@end
