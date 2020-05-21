//
//  ELMessageVideoBubbleView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
*  备注：视频消息内容视图 🐾
*/


#import "ELMessageVideoBubbleView.h"
#import "ElingIM.h"

@implementation ELMessageVideoBubbleView

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
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    [self addSubview:self.shadowView];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.playImgView = [[UIImageView alloc] init];
    self.playImgView.image = [UIImage imageNamed:@"msg_video_white"];
    self.playImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.playImgView];
    [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(@50);
    }];
}

#pragma mark - Setter

- (void)setModel:(ELMessage *)model
{
    if (model.body.type == ELMessageBodyTypeVideo) {
        ELVideoMessageBody *body = (ELVideoMessageBody *)model.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == ELMessageDirectionSend) {
            imgPath = body.localPath;
        }
        [self setImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath imgSize:body.thumbnailSize];
    }
}

@end
