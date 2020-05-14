//
//  ELGroup.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/15.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：群信息模型 🐾
 */

#import <Foundation/Foundation.h>
#import "ELUserInformation.h"

@interface ELGroup : NSObject

/// 群ID
@property (copy, nonatomic) NSString *groupId;
/// 群名称
@property (copy, nonatomic) NSString *groupName;
/// 群主id
@property (copy, nonatomic) NSString *owner;
/// 群头像
@property (copy, nonatomic) NSString *groupAvatar;
/// 群成员列表（包括群主）
@property (strong, nonatomic) NSArray<ELUserInformation *> *memberList;

@end
