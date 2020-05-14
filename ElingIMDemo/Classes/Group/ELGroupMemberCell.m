//
//  ELGroupMemberCell.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/30.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELGroupMemberCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <XCCategory/UIColor+XCExtension.h>

@interface ELGroupMemberCell ()

@end

@implementation ELGroupMemberCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 🛠 👀 Setter Method 👀

- (void)setupUI
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *avatar = [[UIImageView alloc] init];
    [self.contentView addSubview:avatar];
    self.avatar = avatar;
    self.avatar.layer.cornerRadius = 4;
    self.avatar.layer.masksToBounds = YES;
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(50);
        make.centerX.equalTo(@0);
        make.centerY.equalTo(@-10);
    }];
    
    UILabel *nameLB = [[UILabel alloc] init];
    nameLB.textColor = [UIColor colorWithHexString:@"777777"];
    nameLB.font = [UIFont systemFontOfSize:12];
    nameLB.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:nameLB];
    self.nameLB = nameLB;
    
    [nameLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.mas_equalTo(avatar.mas_bottom).offset(10);
    }];
}

#pragma mark - 🛠 👀 Setter Method 👀

- (void)setModel:(ELUserInformation *)model
{
    _model = model;
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
    self.nameLB.text = model.nickName;
}

@end
