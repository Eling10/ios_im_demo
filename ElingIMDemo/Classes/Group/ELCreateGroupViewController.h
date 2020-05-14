//
//  ELCreateGroupViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/30.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：创建群组控制器 🐾
 */

#import "ELBaseViewController.h"

#import <ElingIM/ELGroup.h>
#import <ElingIM/ELUserInformation.h>

@interface ELCreateGroupViewController : ELBaseViewController

/// 创建成功的回调
@property (nonatomic, copy) void (^successCompletion)(void);

@end
