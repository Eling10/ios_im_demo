//
//  EMInviteGroupMemberViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/29.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：添加群成员控制器 🐾
 */

#import "ELSearchViewController.h"
#import "ElingIM.h"

@interface EMInviteGroupMemberViewController : ELSearchViewController

/// 成员列表，如果为空，则获取全部联系人
@property (strong, nonatomic) NSArray<ELUserInformation *> *memberList;

/// 选择完毕的回调
@property (nonatomic, copy) void (^doneCompletion)(NSArray<ELUserInformation *> *aSelectedArray);

/**
 *  创建一个群成员控制器
 *
 *  @param excludeArray 排除成员列表
 */
- (instancetype)initWithExcludeArray:(NSArray<ELUserInformation *> *)excludeArray;

@end
