//
//  ELBadgeLabel.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELBadgeLabel.h"
#import <Masonry/Masonry.h>

@interface ELBadgeLabel ()

@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation ELBadgeLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.font = [UIFont systemFontOfSize:13];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.backgroundColor = [UIColor clearColor];
        [_badgeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_badgeLabel];
        [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(3);
            make.bottom.equalTo(self).offset(-3);
            make.left.equalTo(self).offset(3);
            make.right.equalTo(self).offset(-3);
        }];
    }
    
    return self;
}

- (void)setValue:(NSString *)value
{
    self.badgeLabel.text = value;
}

- (void)setFont:(UIFont *)font
{
    self.badgeLabel.font = font;
}

@end
