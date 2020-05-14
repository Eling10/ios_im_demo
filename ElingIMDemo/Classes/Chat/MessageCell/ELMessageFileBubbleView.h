//
//  ELMessageFileBubbleView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：文件消息内容视图 🐾
 */

#import "ELMessageBubbleView.h"

@interface ELMessageFileBubbleView : ELMessageBubbleView

/// 图标
@property (nonatomic, strong) UIImageView *iconView;
/// 文件名
@property (nonatomic, strong) UILabel *textLabel;
/// 描述
@property (nonatomic, strong) UILabel *detailLabel;

@end
