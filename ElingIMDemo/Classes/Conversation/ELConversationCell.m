//
//  ELConversationCell.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELConversationCell.h"
#import "ELBadgeLabel.h"
#import "ELConversationHelper.h"

#import <Masonry/Masonry.h>
#import <ElingIM/ELConversation.h>
#import <ElingIM/ELTextMessageBody.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ELConversationCell ()

/// 头像
@property (nonatomic, strong) UIImageView *avatarView;
/// 姓名
@property (nonatomic, strong) UILabel *nameLabel;
/// 描述
@property (nonatomic, strong) UILabel *detailLabel;
/// 时间
@property (nonatomic, strong) UILabel *timeLabel;
/// 未读消息数
@property (nonatomic, strong) ELBadgeLabel *badgeLabel;

@end

@implementation ELConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubview];
    }
    
    return self;
}

//
#pragma mark - private layout subviews

- (void)_setupSubview
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
       
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = 4;
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.layer.masksToBounds = YES;
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.width.equalTo(self.avatarView.mas_height).multipliedBy(1);
    }];
       
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [_timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView);
        make.right.equalTo(self.contentView).offset(-15);
    }];
       
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).offset(8);
        make.right.equalTo(self.timeLabel.mas_left);
    }];
       
    _badgeLabel = [[ELBadgeLabel alloc] init];
    _badgeLabel.clipsToBounds = YES;
    _badgeLabel.layer.cornerRadius = 10;
    [self.contentView addSubview:_badgeLabel];
    [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@20);
    }];
       
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.font = [UIFont systemFontOfSize:14];
    _detailLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_detailLabel];
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY).offset(3);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.badgeLabel.mas_left).offset(-5);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
}

- (NSAttributedString *)_getDetailWithModel:(ELConversation *)aConversation
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    ELMessage *lastMessage = [aConversation latestMessage];
    if (!lastMessage) {
        return attributedStr;
    }
    
    NSString *latestMessageTitle = @"";
    ELMessageBody *messageBody = lastMessage.body;
    switch (messageBody.type) {
        case ELMessageBodyTypeText:
            latestMessageTitle = ((ELTextMessageBody *)messageBody).text ?: @"";
            break;
        case ELMessageBodyTypeAudioCall:
            latestMessageTitle = @"[语音通话]";
            break;
        case ELMessageBodyTypeVideoCall:
            latestMessageTitle = @"[视频通话]";
            break;
        case ELMessageBodyTypeFile:
            latestMessageTitle = @"[文件]";
            break;
        case ELMessageBodyTypeImage:
            latestMessageTitle = @"[图片]";
            break;
        case ELMessageBodyTypeVideo:
            latestMessageTitle = @"[视频]";
            break;
        case ELMessageBodyTypeVoice:
            latestMessageTitle = @"[音频]";
            break;
        default:
            break;
    }
    if (lastMessage.chatType != ELChatTypeChat) {   // 群\聊天室
        latestMessageTitle = [NSString stringWithFormat:@"%@：%@", (lastMessage.fromName ?: @""), latestMessageTitle];
    }
    attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
    return attributedStr;
}

- (NSString *)_getTimeWithModel:(ELConversation *)aConversation
{
    NSString *latestMessageTime = @"";
    ELMessage *lastMessage = [aConversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.sendTime;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}


#pragma mark - 🛠 👀 Setter Method 👀

- (void)setModel:(ELConversation *)model
{
    _model = model;

    if (model.latestMessage.chatType == ELChatTypeChat) {   // 单聊
        // 头像
        NSString *avatar = [ELConversationHelper avatarFromConversation:model];
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"touxiang_default"]];
        // 昵称
        self.nameLabel.text = [ELConversationHelper nameFromConversation:model];
    } else {    // 群聊、聊天室
        NSString *avatar = model.latestMessage.toAvatar;
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"group_default"]];
        self.nameLabel.text = model.latestMessage.toName ?: @" ";
    }

    self.detailLabel.attributedText = [self _getDetailWithModel:model];
    self.timeLabel.text = [self _getTimeWithModel:model];
    if (model.unreadMessagesCount == 0) {
        self.badgeLabel.value = @"";
        self.badgeLabel.hidden = YES;
    } else {
        self.badgeLabel.value = [NSString stringWithFormat:@" %@ ", @(model.unreadMessagesCount).description];
        self.badgeLabel.hidden = NO;
    }
}

@end
