//
//  ELRootViewControllerHelper.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ELRootViewControllerType) {
    ELRootViewControllerTypeLogin = 0,  // 登录
    ELRootViewControllerTypeHome        // 首页
};


@interface ELRootViewControllerHelper : NSObject

/**
 *  选择根视图控制顺 --- 根据当前登录的状态自动选择
 */
+ (void)chooseRootViewController;

/**
 *  选择指定类型的根视图控制器
 *
 *  @param type 根视图控制器的类型
 */
+ (void)chooseRootViewControllerWithType:(ELRootViewControllerType)type;

@end
