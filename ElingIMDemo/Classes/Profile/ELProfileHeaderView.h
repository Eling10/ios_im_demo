//
//  ELProfileHeaderView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELWaveView.h"

@interface ELProfileHeaderView : UIView

/// 波浪视图
@property (weak, nonatomic) ELWaveView *waveView;
/// 头像
@property (weak, nonatomic) UIImageView *icon;
/// 昵称
@property (weak, nonatomic) UILabel *nickNameLB;

@end
