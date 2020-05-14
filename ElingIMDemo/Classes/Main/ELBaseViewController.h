//
//  ELBaseViewController.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELBaseViewController : UIViewController

/** 默认隐藏,  yes:隐藏； no:显示 */
@property (nonatomic, assign, getter=isHideNavigationBar) BOOL hideNavigationBar;

/** tableView 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 👀 分页数量（只针对有上拉加载更多的时候）：默认为 15 👀 */
@property (assign, nonatomic) NSInteger pageSize;

/** 👀 分页数（第几页）：默认为 1 👀 */
@property (assign, nonatomic) NSInteger page;

@end

NS_ASSUME_NONNULL_END
