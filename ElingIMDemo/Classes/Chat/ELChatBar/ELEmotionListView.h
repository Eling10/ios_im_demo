//
//  ELEmotionListView.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
 *  备注：表情容器视图 🐾
 */

#import <UIKit/UIKit.h>
#import "ELEmotionModel.h"

@interface ELEmotionListView : UIView

/// 所有的表情数据（不包括删除按钮）
@property (strong, nonatomic) NSArray<ELEmotionModel *> *emotions;

@end
