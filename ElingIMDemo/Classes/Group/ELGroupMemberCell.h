//
//  ELGroupMemberCell.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/30.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElingIM.h"

@interface ELGroupMemberCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *nameLB;
@property (weak, nonatomic) UIImageView *avatar;

@property (strong, nonatomic) ELUserInformation *model;

@end
