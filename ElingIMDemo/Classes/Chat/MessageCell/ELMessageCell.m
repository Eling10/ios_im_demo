//
//  ELMessageCell.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELMessageCell.h"
#import "ELMessageTextBubbleView.h"
#import "ELMessageFileBubbleView.h"
#import "ELMessageImageBubbleView.h"
#import "ELMessageVideoBubbleView.h"
#import "ELMessageAudioBubbleView.h"

#import "ELColorMacros.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ELMessageCell ()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ELMessageCell

#pragma mark - 🔓 👀 Public Method 👀

+ (NSString *)cellIdentifierWithDirection:(ELMessageDirection)aDirection
                                     type:(ELMessageBodyType)aType
{
    NSString *identifier = @"ELCellIdentifierSend";
    if (aDirection == ELMessageDirectionReceive) {
        identifier = @"ELCellIdentifierReceive";
    }
    
    if (aType == ELMessageBodyTypeText || aType == ELMessageBodyTypeAudioCall || aType == ELMessageBodyTypeVideoCall) {
        identifier = [NSString stringWithFormat:@"%@Text", identifier];
    } else if (aType == ELMessageBodyTypeImage) {
        identifier = [NSString stringWithFormat:@"%@Image", identifier];
    } else if (aType == ELMessageBodyTypeVoice) {
        identifier = [NSString stringWithFormat:@"%@Voice", identifier];
    } else if (aType == ELMessageBodyTypeVideo) {
        identifier = [NSString stringWithFormat:@"%@Video", identifier];
    } else if (aType == ELMessageBodyTypeFile) {
        identifier = [NSString stringWithFormat:@"%@File", identifier];
    }
    
    return identifier;
}

- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType
{
    NSString *identifier = [ELMessageCell cellIdentifierWithDirection:aDirection type:aType];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        _direction = aDirection;
        [self _setupViewsWithType:aType];
    }
    
    return self;
}

#pragma mark - 🛠 👀 Setter Method 👀

- (void)setModel:(ELMessage *)model
{
    _model = model;
    
    self.bubbleView.model = model;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.fromAvatar] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
    if (model.direction == ELMessageDirectionReceive) {
        self.nameLabel.text = model.fromName;
    }
}

#pragma mark - 🎬 👀 Action Method 👀

- (void)bubbleViewTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellDidSelect:)]) {
            [self.delegate messageCellDidSelect:self];
        }
    }
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  设置子视图
 */
- (void)_setupViewsWithType:(ELMessageBodyType)aType
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = ELVIEW_BACKGROUND_COLOR;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = 4;
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarView];
    if (self.direction == ELMessageDirectionSend) {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-10);
            make.width.height.equalTo(@40);
        }];
    } else {
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(10);
            make.width.height.equalTo(@40);
        }];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.equalTo(self.contentView).offset(-10);
        }];
    }
    
    _bubbleView = [self _getBubbleViewWithType:aType];
    _bubbleView.userInteractionEnabled = YES;
    _bubbleView.clipsToBounds = YES;
    [self.contentView addSubview:_bubbleView];
    if (self.direction == ELMessageDirectionSend) {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.greaterThanOrEqualTo(self.contentView).offset(70);
            make.right.equalTo(self.avatarView.mas_left).offset(-10);
        }];
    } else {
        [_bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(3);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.avatarView.mas_right).offset(10);
            make.right.lessThanOrEqualTo(self.contentView).offset(-70);
        }];
    }
}

/**
 *  获取 bubbleView
 */
- (ELMessageBubbleView *)_getBubbleViewWithType:(ELMessageBodyType)aType
{
    ELMessageBubbleView *bubbleView = nil;
    if (aType == ELMessageBodyTypeText || aType == ELMessageBodyTypeAudioCall || aType == ELMessageBodyTypeVideoCall) {
        bubbleView = [[ELMessageTextBubbleView alloc] initWithDirection:self.direction type:aType];
    } else if (aType == ELMessageBodyTypeImage) {
        bubbleView = [[ELMessageImageBubbleView alloc] initWithDirection:self.direction type:aType];
    } else if (aType == ELMessageBodyTypeVoice) {
        bubbleView = [[ELMessageAudioBubbleView alloc] initWithDirection:self.direction type:aType];
    } else if (aType == ELMessageBodyTypeVideo) {
        bubbleView = [[ELMessageVideoBubbleView alloc] initWithDirection:self.direction type:aType];
    } else if (aType == ELMessageBodyTypeFile) {
        bubbleView = [[ELMessageFileBubbleView alloc] initWithDirection:self.direction type:aType];
    }
    
    if (bubbleView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [bubbleView addGestureRecognizer:tap];
    }
    
    return bubbleView;
}

@end
