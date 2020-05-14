//
//  ELNavigationController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELNavigationController : UINavigationController

/**
 *  点击导航栏左侧按钮的回调
 *
 *  如果设置了该属性，则点击导航栏左侧按钮的时候就不会执行默认的 POP 操作
 */
@property (copy, nonatomic) void(^didClickLeftItemCallBack)(void);

@end
