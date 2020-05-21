//
//  ELMessageCell.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ElingIM.h"
#import "ELMessageBubbleView.h"


@class ELMessageCell;
@protocol ELMessageCellDelegate <NSObject>
@optional
/**
 *  选中某个cell的回调
 */
- (void)messageCellDidSelect:(ELMessageCell *)aCell;
@end


@interface ELMessageCell : UITableViewCell

/// 内容视图
@property (strong, nonatomic, readonly) ELMessageBubbleView *bubbleView;
/// 消息的方向
@property (assign, nonatomic, readonly) ELMessageDirection direction;

/// 消息对象
@property (strong, nonatomic) ELMessage *model;
/// 代理
@property (weak, nonatomic) id<ELMessageCellDelegate> delegate;

/**
 *  根据 消息的方向 和 消息的类别获取一个 cell 的复用标识符
 *
 *  @param aDirection 消息的方向
 *  @param aType 消息类别
 */
+ (NSString *)cellIdentifierWithDirection:(ELMessageDirection)aDirection
                                     type:(ELMessageBodyType)aType;

/**
 *  根据 消息的方向 和 消息的类别获取一个消息的 cell
 *
 *  @param aDirection 消息的方向
 *  @param aType 消息类别
 */
- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType;

@end
