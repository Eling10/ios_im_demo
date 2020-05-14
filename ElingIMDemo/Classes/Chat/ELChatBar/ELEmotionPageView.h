//
//  ELEmotionPageView.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
 *  备注：表情内容视图（单页） 🐾
 */

#import <UIKit/UIKit.h>
#import "ELEmotionModel.h"

@interface ELEmotionPageView : UIView

/// 单页的表情数据
@property (strong, nonatomic) NSArray<ELEmotionModel *> *emotions;

@end
