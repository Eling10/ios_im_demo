//
//  ELEmotionListView.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
*  备注：表情容器视图 🐾
*/

#import "ELEmotionListView.h"
#import "ELChatBarConst.h"
#import "ELEmotionPageView.h"

#import <XCMacros/XCMacros.h>
#import <XCCategory/UIView+XCExtension.h>

@interface ELEmotionListView ()<UIScrollViewDelegate>

/// 表情滚动视图
@property(nonatomic, strong) UIScrollView *scrollview;
@property(nonatomic, strong) UIPageControl *pageControl;

@end


@implementation ELEmotionListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self scrollview];
        [self pageControl];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // pageControl
    self.pageControl.width  = self.width;
    self.pageControl.height = 10;
    self.pageControl.left   = 0;
    self.pageControl.top    = self.height - self.pageControl.height - 5;
    // scrollView
    self.scrollview.width  = self.width;
    self.scrollview.height = self.pageControl.top;
    self.scrollview.left   = self.scrollview.top = 0;
    // emotionPageView
    NSUInteger count = self.scrollview.subviews.count;
    for (int i = 0 ; i < count; i++) {
        ELEmotionPageView *pageview = self.scrollview.subviews[i];
        pageview.width  = self.scrollview.width ;
        pageview.height = self.scrollview.height;
        pageview.left   = i * pageview.width;
        pageview.top   = 0;
    }
    self.scrollview.contentSize = CGSizeMake(count * self.scrollview.width, 0);
}

#pragma mark - 🔑 👀 Getter Method 👀

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        [self addSubview:_pageControl];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}
- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview =[[UIScrollView alloc] init];
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.pagingEnabled = YES;
        _scrollview.delegate = self;
        [self addSubview:_scrollview];
    }
    return _scrollview;
}

#pragma mark - 🛠 👀 Setter Method 👀

- (void)setEmotions:(NSArray<ELEmotionModel *> *)emotions
{
    _emotions = emotions;
    [self.scrollview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSUInteger count = (emotions.count + ELEmotionPageSize - 1) / ELEmotionPageSize;
    self.pageControl.numberOfPages = count;
    for (int i = 0; i<count; i++) {
        ELEmotionPageView *pageView = [[ELEmotionPageView alloc] init];
        NSRange range;
        range.location  =   i * ELEmotionPageSize;
        NSUInteger left =   emotions.count - range.location; // 剩余
        if (left >= ELEmotionPageSize) {
            range.length = ELEmotionPageSize;
        }else{
            range.length = left;
        }
        pageView.emotions = [emotions subarrayWithRange:range];
        [self.scrollview addSubview:pageView];
    }
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 更新  pageControl
    double pageNum = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage  = (NSInteger)(pageNum + 0.5);
}

@end
