//
//  UIScrollView+Refresh.m
//  MJRefresh测试
//
//  Created by 樊小聪 on 2017/3/15.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import "UIScrollView+Refresh.h"


#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>


static NSString * const loadNewDataHandleKey  = @"loadNewDataHandle";
static NSString * const loadMoreDataHandleKey = @"loadMoreDataHandle";


@implementation UIScrollView (Refresh)

#pragma mark - 👀 Setter --- Getter Method 👀 💤

- (void)setLoadNewDataHandle:(RefreshLoadNewDataHandle)loadNewDataHandle
{
    [self willChangeValueForKey:loadNewDataHandleKey];
    
    objc_setAssociatedObject(self, @selector(loadNewDataHandle), loadNewDataHandle, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self didChangeValueForKey:loadNewDataHandleKey];
    
    /// 设置 头部
    if (!self.mj_header)
    {
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.automaticallyChangeAlpha = YES;
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;
        
        // 马上进入刷新状态
        //        [header beginRefreshing];
        
        // 设置文字
        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"松开立即刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"正在刷新中 ..." forState:MJRefreshStateRefreshing];
        // 设置字体
        header.stateLabel.font = [UIFont systemFontOfSize:14];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12];
        // 设置颜色
        header.stateLabel.textColor = [UIColor lightGrayColor];
        header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        
        // 设置header
        self.mj_header = header;
    }
}

- (RefreshLoadNewDataHandle)loadNewDataHandle
{
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setLoadMoreDataHandle:(RefreshLoadMoreDataHandle)loadMoreDataHandle
{
    [self willChangeValueForKey:loadMoreDataHandleKey];
    
    objc_setAssociatedObject(self, @selector(loadMoreDataHandle), loadMoreDataHandle, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self didChangeValueForKey:loadMoreDataHandleKey];
    
    /// 设置 尾部
    if (!self.mj_footer)
    {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        footer.automaticallyHidden = YES;
        // 设置文字
        [footer setTitle:@"" forState:MJRefreshStateIdle];//加载更多
        [footer setTitle:@"加载中，请稍后..." forState:MJRefreshStateRefreshing];
        [footer setTitle:kFooterNoMoreDataText forState:MJRefreshStateNoMoreData];
        // 设置字体
        footer.stateLabel.font = [UIFont systemFontOfSize:14];
        // 设置颜色
        footer.stateLabel.textColor = [UIColor lightGrayColor];
        
        self.mj_footer = footer;
    }
}

- (RefreshLoadMoreDataHandle)loadMoreDataHandle
{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  加载新数据
 */
- (void)loadNewData
{
//    /// 重置状态
//    if (self.mj_footer)
//    {
//        [self.mj_footer resetNoMoreData];
//    }
//    
    /// 回调
    if (self.loadNewDataHandle)
    {
        self.loadNewDataHandle();
    }
}

/**
 *  加载更多数据
 */
- (void)loadMoreData
{
    /// 回调
    if (self.loadMoreDataHandle)
    {
        self.loadMoreDataHandle();
    }
}

#pragma mark - 🔓 👀 Public Method 👀

/**
 *  开始刷新
 */
- (void)beginRefreshing
{
    if (self.mj_header)
    {
        [self.mj_header beginRefreshing];
    }
}

/**
 *  结束刷新
 */
- (void)endRefreshing
{
    /// 结束下拉刷新
    if (self.mj_header.isRefreshing)
    {
        [self.mj_header endRefreshing];
    }
    
    /// 结束上拉加载
    if (self.mj_footer.isRefreshing)
    {
        [self.mj_footer endRefreshing];
    }
}

/**
 *  上拉加载更多。。。显示没有更多数据了
 */
- (void)endRefreshingWithNoMoreData
{
    /// 结束上拉加载
    if (self.mj_footer)
    {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
}

/**
 *  重置没有更多的数据（消除没有更多数据的状态）
 */
- (void)resetNoMoreData
{
    if (self.mj_footer)
    {
        [self.mj_footer resetNoMoreData];
    }
}

@end


