//
//  UIScrollView+Refresh.h
//  MJRefresh测试
//
//  Created by 樊小聪 on 2017/3/15.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshLoadNewDataHandle)(void);
typedef void(^RefreshLoadMoreDataHandle)(void);


//static NSString *const kFooterNoMoreDataText = @"—————   没有更多内容了   —————";
static NSString *const kFooterNoMoreDataText = @"";


@interface UIScrollView (Refresh)

/** 👀 下拉重新加载的回调 👀 */
@property (copy, nonatomic) RefreshLoadNewDataHandle loadNewDataHandle;

/** 👀 上拉加载更多的回调 👀 */
@property (copy, nonatomic) RefreshLoadMoreDataHandle loadMoreDataHandle;


/**
 *  开始刷新
 */
- (void)beginRefreshing;

/**
 *  结束刷新
 */
- (void)endRefreshing;

/**
 *  结束上拉加载更多。。。显示没有更多数据了
 */
- (void)endRefreshingWithNoMoreData;

/**
 *  重置没有更多的数据（消除没有更多数据的状态）
 */
- (void)resetNoMoreData;

@end
