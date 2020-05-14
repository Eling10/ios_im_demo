//
//  ELGroupMemberListViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/6.
//  Copyright © 2020 樊小聪. All rights reserved.
//


/*
 *  备注：群组成员列表控制器 🐾
 */

#import "ELBaseViewController.h"

@interface ELGroupMemberListViewController : ELBaseViewController

/// 群ID
@property (copy, nonatomic) NSString *groupId;

/// 群组成员数发生改变的回调
@property (copy, nonatomic) void(^groupMemberListDidChangeCallback)(void);

@end
