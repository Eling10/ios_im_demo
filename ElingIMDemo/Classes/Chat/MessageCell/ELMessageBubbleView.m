//
//  ELMessageBubbleView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELMessageBubbleView.h"

@implementation ELMessageBubbleView

#pragma mark - 🔓 👀 Public Method 👀

- (instancetype)initWithDirection:(ELMessageDirection)aDirection
                             type:(ELMessageBodyType)aType
{
    self = [super init];
    if (self) {
        _direction = aDirection;
        _type = aType;
    }
    return self;
}

- (void)setupBubbleBackgroundImage
{
    if (self.direction == ELMessageDirectionSend) {
        self.image = [[UIImage imageNamed:@"msg_bg_send"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    } else {
        self.image = [[UIImage imageNamed:@"msg_bg_recv"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
}

@end
