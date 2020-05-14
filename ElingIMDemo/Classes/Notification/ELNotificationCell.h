//
//  ELNotificationCell.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ELNotificationModel;
@protocol EMNotificationCellDelegate <NSObject>
@optional
/**
 *  同意
 */
- (void)agreeNotification:(ELNotificationModel *)aModel;
/**
 *  拒绝
 */
- (void)declineNotification:(ELNotificationModel *)aModel;
@end

@interface ELNotificationCell : UITableViewCell

/// 数据模型
@property (strong, nonatomic) ELNotificationModel *model;
/// 代理
@property (weak, nonatomic) id<EMNotificationCellDelegate> delegate;

@end
