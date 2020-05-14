//
//  ELNotificationViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：通知控制器（加好友、加群、退群通知） 🐾
 */

#import "ELBaseViewController.h"

@interface ELNotificationViewController : ELBaseViewController

/// 同意 后的回调
@property (copy, nonatomic) void(^acceptActionCallback)(void);

@end
