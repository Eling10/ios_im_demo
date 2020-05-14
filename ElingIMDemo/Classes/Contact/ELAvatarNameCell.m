//
//  ELAvatarNameCell.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELAvatarNameCell.h"
#import <Masonry/Masonry.h>

@implementation ELAvatarNameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = 4;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.numberOfLines = 2;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

#pragma mark - Public

- (void)setAccessoryButton:(UIButton *)accessoryButton
{
    _accessoryButton = accessoryButton;
    if (_accessoryButton) {
        [_accessoryButton addTarget:self action:@selector(accessoryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    self.accessoryView = accessoryButton;
}

#pragma mark - Action

- (void)accessoryButtonAction
{
    if (self.clickAccessoryButtonCallback) {
        self.clickAccessoryButtonCallback();
    }
}

@end
