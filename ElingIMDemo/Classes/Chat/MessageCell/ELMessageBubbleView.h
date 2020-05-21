//
//  ELMessageBubbleView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "ElingIM.h"

@interface ELMessageBubbleView : UIImageView

/// 消息的方向
@property (assign, nonatomic, readonly) ELMessageDirection direction;
/// 消息类型
@property (assign, nonatomic, readonly) ELMessageBodyType type;

/// 消息对象
@property (strong, nonatomic) ELMessage *model;

/**
 *  根据 消息方向、消息体类型初始化一个消息的内容视图
 *
 *  @param aDirection 消息方向
 *  @param aType 消息类别
 */
- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType;

/**
 *  设置消息的背景图片，由子类调用（不需要背景的消息内容不用调用）
 */
- (void)setupBubbleBackgroundImage;

@end
