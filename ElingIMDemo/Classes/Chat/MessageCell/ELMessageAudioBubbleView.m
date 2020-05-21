//
//  ELMessageAudioBubbleView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
*  备注：语音消息内容视图 🐾
*/

#import "ELMessageAudioBubbleView.h"
#import "ElingIM.h"

#define kELMessageAudioMinWidth 30
#define kELMessageAudioMaxWidth 120

@implementation ELMessageAudioBubbleView

- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType
{
    self = [super initWithDirection:aDirection type:aType];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - 🔒 👀 Privite Method 👀

- (void)_setupSubviews
{
    [self setupBubbleBackgroundImage];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.clipsToBounds = YES;
    [self addSubview:self.imgView];
    self.imgView.animationDuration = 1.0;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.width.height.equalTo(@30);
    }];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self.imgView.mas_left).offset(-10);
        make.bottom.equalTo(self).offset(-10);
    }];
    
    if (self.direction == ELMessageDirectionSend) {
        self.imgView.image = [UIImage imageNamed:@"msg_send_audio"];
        self.imgView.animationImages = @[[UIImage imageNamed:@"msg_send_audio01"],
                                         [UIImage imageNamed:@"msg_send_audio02"],
                                         [UIImage imageNamed:@"msg_send_audio"]];
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.imgView.image = [UIImage imageNamed:@"msg_recv_audio"];
        self.imgView.animationImages = @[[UIImage imageNamed:@"msg_recv_audio01"],
                                         [UIImage imageNamed:@"msg_recv_audio02"],
                                         [UIImage imageNamed:@"msg_recv_audio"]];
        self.textLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - Setter

- (void)setModel:(ELMessage *)model
{
    if (model.body.type == ELMessageBodyTypeVoice) {
        ELVoiceMessageBody *body = (ELVoiceMessageBody *)model.body;
        self.textLabel.text = [NSString stringWithFormat:@"%d\"",(int)body.duration];
        if (body.isPlaying) {
            [self.imgView startAnimating];
        } else {
            [self.imgView stopAnimating];
        }
        
        CGFloat width = kELMessageAudioMinWidth * body.duration / 10;
        if (width > kELMessageAudioMaxWidth) {
            width = kELMessageAudioMaxWidth;
        } else if (width < kELMessageAudioMinWidth) {
            width = kELMessageAudioMinWidth;
        }
        [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
    }
}


@end
