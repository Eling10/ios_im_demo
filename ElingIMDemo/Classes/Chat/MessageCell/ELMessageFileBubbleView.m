//
//  ELMessageFileBubbleView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
*  备注：文件消息内容视图 🐾
*/

#import "ELMessageFileBubbleView.h"
#import <ElingIM/ELFileMessageBody.h>

@implementation ELMessageFileBubbleView

- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType
{
    self = [super initWithDirection:aDirection type:aType];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    [self setupBubbleBackgroundImage];
    
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.clipsToBounds = YES;
    [self addSubview:self.iconView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:18];
    self.textLabel.numberOfLines = 0;
    [self addSubview:self.textLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    self.detailLabel.numberOfLines = 0;
    [self addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textLabel.mas_bottom);
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self.textLabel);
        make.right.equalTo(self.textLabel);
    }];
    
    if (self.direction == ELMessageDirectionSend) {
        self.iconView.image = [UIImage imageNamed:@"msg_file_white"];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(5);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
        }];
        
        self.textLabel.textColor = [UIColor whiteColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self.iconView.mas_right).offset(5);
            make.right.equalTo(self).offset(-15);
        }];
        
        self.detailLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    } else {
        self.iconView.image = [UIImage imageNamed:@"msg_file"];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(8);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
        }];
        
        self.textLabel.textColor = [UIColor blackColor];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self.iconView.mas_right).offset(5);
            make.right.equalTo(self).offset(-10);
        }];
        
        self.detailLabel.textColor = [UIColor grayColor];
    }
}

#pragma mark - Setter

- (void)setModel:(ELMessage *)model
{
    if (model.body.type == ELMessageBodyTypeFile) {
        ELFileMessageBody *body = (ELFileMessageBody *)model.body;
        self.textLabel.text = body.displayName;
        self.detailLabel.text = [NSString stringWithFormat:@"%.2lf MB",(float)body.fileLength / (1024 * 1024)];
    }
}

@end
