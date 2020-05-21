//
//  ELMessageImageBubbleView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELMessageImageBubbleView.h"
#import "ElingIM.h"
#import <XCMacros/XCMacros.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define kELMessageImageDefaultSize  120
#define kELMessageImageMinWidth     50
#define kELMessageImageMaxWidth     120
#define kELMessageImageMaxHeight    260

@implementation ELMessageImageBubbleView

- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType
{
    if (self = [super initWithDirection:aDirection type:aType]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

#pragma mark - Private

- (CGSize)_getImageSize:(CGSize)aSize
{
    CGSize retSize = CGSizeMake(kELMessageImageDefaultSize, kELMessageImageDefaultSize);
    do {
        if (aSize.width == 0 || aSize.height == 0) {
            break;
        }
        
        NSInteger tmpWidth = aSize.width;
        if (aSize.width < kELMessageImageMinWidth) {
            tmpWidth = kELMessageImageMinWidth;
        }
        if (aSize.width > kELMessageImageMaxWidth) {
            tmpWidth = kELMessageImageMaxWidth;
        }
        
        NSInteger tmpHeight = tmpWidth / aSize.width * aSize.height;
        if (tmpHeight > kELMessageImageMaxHeight) {
            tmpHeight = kELMessageImageMaxHeight;
        }
        
        retSize.width = tmpWidth;
        retSize.height = tmpHeight;
        
    } while (0);
    
    return retSize;
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)setImageWithLocalPath:(NSString *)aLocalPath
                   remotePath:(NSString *)aRemotePath
                      imgSize:(NSDictionary *)aSize
{    
    UIImage *img = nil;
    // 如果本地已经缓存过图片，则直接加载本地图片
    if ([aLocalPath length] > 0) {
        img = [UIImage imageWithContentsOfFile:aLocalPath];
    }

    // 更新图片尺寸
    @weakify(self);
    void (^block)(CGSize aSize) = ^(CGSize aSize) {
        @strongify(self);
        CGSize layoutSize = [self _getImageSize:aSize];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(layoutSize.width);
            make.height.mas_equalTo(layoutSize.height);
        }];
    };
      
    CGSize size = CGSizeZero;
    if ([aSize isKindOfClass:[NSDictionary class]]) {
        size = CGSizeMake([aSize[@"width"] floatValue], [aSize[@"height"] floatValue]);
    }
      
    if (img) {
        self.image = img;
        size = img.size;
    } else {
        // 加载网络图片
        [self sd_setImageWithURL:[NSURL URLWithString:aRemotePath]];
    }
      
    block(size);
}

#pragma mark - Setter

- (void)setModel:(ELMessage *)model
{
    if (model.body.type == ELMessageBodyTypeImage) {
        ELImageMessageBody *body = (ELImageMessageBody *)model.body;
        NSString *imgPath = body.thumbnailLocalPath;
        if ([imgPath length] == 0 && model.direction == ELMessageDirectionSend) {
            imgPath = body.localPath;
        }
        [self setImageWithLocalPath:imgPath remotePath:body.thumbnailRemotePath imgSize:body.size];
    }
}

@end
