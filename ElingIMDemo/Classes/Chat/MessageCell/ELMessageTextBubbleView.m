//
//  ELMessageTextBubbleView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELMessageTextBubbleView.h"
#import "ElingIM.h"

@implementation ELMessageTextBubbleView

- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType
{
    if (self = [super initWithDirection:aDirection type:aType]) {
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  设置子视图
 */
- (void)_setupSubviews
{
    [self setupBubbleBackgroundImage];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    
    if (self.direction == ELMessageDirectionSend) { // 我发送的消息
        self.textLabel.textColor = [UIColor whiteColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
    } else {    // 我接收的消息
        self.textLabel.textColor = [UIColor blackColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
    }
}

/**
 *  格式化通话时长
 *
 *  @param seconds 时长（秒）
 */
- (NSString *)_getDuration:(NSInteger)seconds
{
    NSInteger hour = seconds / 3600;
    NSInteger m = (seconds - hour * 3600) / 60;
    NSInteger s = seconds - hour * 3600 - m * 60;
    
    if (hour > 0) {
        return [NSString stringWithFormat:@"%02zi:%02zi:%02zi", hour, m, s];
    } else if(m > 0) {
        return [NSString stringWithFormat:@"%02zi:%02zi", m, s];
    } else {
        return [NSString stringWithFormat:@"00:%02zi", s];
    }
}

#pragma mark - Setter

- (void)setModel:(ELMessage *)model
{
    if (model.body.type == ELMessageBodyTypeText) {
        ELTextMessageBody *body = (ELTextMessageBody *)model.body;
        self.textLabel.text = body.text;
    } else if (model.body.type == ELMessageBodyTypeAudioCall || model.body.type == ELMessageBodyTypeVideoCall) {
        ELCallMessageBody *body = (ELCallMessageBody *)model.body;
        self.textLabel.text = [NSString stringWithFormat:@"通话时长 %@", [self _getDuration:body.duration]];
    }
}

@end
