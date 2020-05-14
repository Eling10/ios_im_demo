//
//  ELAvatarNameCell.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ELAvatarNameCell : UITableViewCell

/// 点击右侧按钮的回调
@property (copy, nonatomic) void(^clickAccessoryButtonCallback)(void);
/// 索引
@property (nonatomic, strong) NSIndexPath *indexPath;
/// 头像
@property (nonatomic, strong) UIImageView *avatarView;
/// 名称
@property (nonatomic, strong) UILabel *nameLabel;
/// 右侧按钮
@property (nonatomic, strong) UIButton *accessoryButton;

@end
