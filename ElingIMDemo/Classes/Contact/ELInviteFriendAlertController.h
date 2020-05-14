//
//  ELInviteFriendAlertController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELBaseViewController.h"

@interface ELInviteFriendAlertController : ELBaseViewController

/// 点击确认按钮的回调
@property (copy, nonatomic) void(^clickEnterButtonCallback)(NSString *text);

@end
