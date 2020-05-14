//
//  ELProfileHeaderView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELProfileHeaderView.h"
#import <Masonry/Masonry.h>
#import <XCCategory/UIColor+XCExtension.h>

@implementation ELProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置 UI
        [self setupUI];
    }
    return self;
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    // 头像
    UIImageView *icon = [UIImageView new];
    self.icon = icon;
    self.icon.layer.cornerRadius = 30;
    self.icon.layer.masksToBounds = YES;
    [self addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(60);
        make.center.equalTo(self);
    }];
    
    // 昵称
    UILabel *nickNameLB = [UILabel new];
    self.nickNameLB = nickNameLB;
    self.nickNameLB.font = [UIFont systemFontOfSize:16];
    self.nickNameLB.textColor = [UIColor whiteColor];
    self.nickNameLB.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.nickNameLB];
    [self.nickNameLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.icon);
        make.top.equalTo(self.icon.mas_bottom).offset(10);
    }];
    
    // 波浪
    ELWaveView *waveView = [[ELWaveView alloc] initWithFrame:self.bounds];
    self.waveView = waveView;
    [self addSubview:self.waveView];
}

@end
