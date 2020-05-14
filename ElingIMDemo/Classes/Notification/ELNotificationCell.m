//
//  ELNotificationCell.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELNotificationCell.h"
#import "ELColorMacros.h"
#import "ELNotificationModel.h"
#import <Masonry/Masonry.h>
#import <XCDateUnit/XCDateUnit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define kColor_Gray [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0]
#define kColor_Blue [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0]

@interface ELNotificationCell()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *msgLabel;

@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *declineButton;
@property (nonatomic, strong) UIButton *agreeButton;

@end

@implementation ELNotificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@40);
    }];
    
    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.clipsToBounds = YES;
    self.cardView.layer.cornerRadius = 5;
    [self.contentView addSubview:self.cardView];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-15);
    }];
    
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.layer.cornerRadius = 4;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.backgroundColor = [UIColor clearColor];
    [self.cardView addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardView).offset(10);
        make.left.equalTo(self.cardView).offset(10);
        make.width.height.equalTo(@50);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.nameLabel.numberOfLines = 0;
    [self.cardView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.left.equalTo(self.avatarView.mas_right).offset(10);
        make.right.equalTo(self.cardView).offset(-10);
    }];
    
    self.msgLabel = [[UILabel alloc] init];
    self.msgLabel.backgroundColor = [UIColor clearColor];
    self.msgLabel.textColor = [UIColor lightGrayColor];
    self.msgLabel.font = [UIFont systemFontOfSize:15];
    self.msgLabel.numberOfLines = 0;
    [self.cardView addSubview:self.msgLabel];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(8);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
        make.height.greaterThanOrEqualTo(@20);
    }];
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = ELCELL_SEPRATOR_COLOR;
    [self.cardView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.msgLabel.mas_bottom).offset(15);
        make.left.equalTo(self.cardView);
        make.right.equalTo(self.cardView);
        make.height.equalTo(@0.5);
    }];
}

#pragma mark - Getter

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.enabled = NO;
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.cardView addSubview:_doneButton];
        [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.msgLabel.mas_bottom).offset(10);
            make.left.equalTo(self.cardView);
            make.right.equalTo(self.cardView);
            make.height.equalTo(@45);
            make.bottom.equalTo(self.cardView);
        }];
    }
    
    return _doneButton;
}

- (UIButton *)declineButton
{
    if (_declineButton == nil) {
        _declineButton = [[UIButton alloc] init];
        _declineButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_declineButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_declineButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_declineButton addTarget:self action:@selector(declineButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_declineButton];
        [_declineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.msgLabel.mas_bottom).offset(10);
            make.left.equalTo(self.cardView);
            make.right.equalTo(self.cardView.mas_centerX);
            make.height.equalTo(@45);
            make.bottom.equalTo(self.cardView);
        }];
    }
    
    return _declineButton;
}

- (UIButton *)agreeButton
{
    if (_agreeButton == nil) {
        _agreeButton = [[UIButton alloc] init];
        _agreeButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_agreeButton setTitle:@"同意" forState:UIControlStateNormal];
        [_agreeButton setTitleColor:kColor_Blue forState:UIControlStateNormal];
        [_agreeButton addTarget:self action:@selector(agreeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_agreeButton];
        [_agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.msgLabel.mas_bottom).offset(10);
            make.left.equalTo(self.cardView.mas_centerX);
            make.right.equalTo(self.cardView);
            make.height.equalTo(@45);
            make.bottom.equalTo(self.cardView);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = kColor_Gray;
        [self.cardView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.msgLabel.mas_bottom).offset(10);
            make.left.equalTo(self.cardView.mas_centerX).offset(-0.5);
            make.width.equalTo(@1);
            make.bottom.equalTo(self.cardView);
        }];
    }
    
    return _agreeButton;
}

#pragma mark - Setter

- (void)setModel:(ELNotificationModel *)model
{
    _model = model;
    
    self.timeLabel.text = [XCDateUnit stringFromMilliseconds:model.time format:@"yyyy-MM-dd HH:mm"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ 请求添加您为好友", (model.senderName ?: @"")];
    self.msgLabel.text = model.message;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.senderAvatar] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
    if (model.status == ELNotificationModelStatusDefault) {
        [self declineButton];
        [self agreeButton];
    } else {
        NSString *str = @"已同意";
        if (model.status == ELNotificationModelStatusDeclined) {
            str = @"已拒绝";
        } 
        [self.doneButton setTitle:str forState:UIControlStateNormal];
    }
}

#pragma mark - Action

- (void)agreeButtonAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(agreeNotification:)]) {
        [_delegate agreeNotification:self.model];
    }
}

- (void)declineButtonAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(declineNotification:)]) {
        [_delegate declineNotification:self.model];
    }
}

@end
