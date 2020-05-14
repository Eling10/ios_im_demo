//
//  ELEmotionView.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import "ELEmotionView.h"
#import "ELEmotionListView.h"
#import "ELEmotionMenuView.h"
#import <MJExtension/MJExtension.h>
#import <XCCategory/UIView+XCExtension.h>

@interface ELEmotionView ()

/// 表情视图
@property (strong, nonatomic) ELEmotionListView *emotionListView;
/// 表情底部菜单视图（发送表情按钮）
@property (strong, nonatomic) ELEmotionMenuView *emotionMenuView;

@end

@implementation ELEmotionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 添加子视图
        [self addSubview:self.emotionMenuView];
        [self addSubview:self.emotionListView];
        // 加载表情数据，只加载一次
        static NSString *emotionJson;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            emotionJson = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji_data" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
        });
        self.emotionListView.emotions = [ELEmotionModel mj_objectArrayWithKeyValuesArray:emotionJson];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.emotionMenuView.width = self.width;
    self.emotionMenuView.height = 40.;
    self.emotionMenuView.left = 0;
    self.emotionMenuView.top = self.height - self.emotionMenuView.height;
    
    self.emotionListView.left = self.emotionListView.top = 0;
    self.emotionListView.width = self.width;
    self.emotionListView.height = self.emotionMenuView.top;
}

#pragma mark - 🔑 👀 Getter Method 👀

- (ELEmotionListView *)emotionListView
{
    if (!_emotionListView) {
        _emotionListView = [[ELEmotionListView alloc] init];
    }
    return _emotionListView;
}

- (ELEmotionMenuView *)emotionMenuView
{
    if (!_emotionMenuView) {
        _emotionMenuView = [[ELEmotionMenuView alloc] init];
    }
    return _emotionMenuView;
}

@end
