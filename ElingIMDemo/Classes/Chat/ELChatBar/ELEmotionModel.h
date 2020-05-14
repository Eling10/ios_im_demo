//
//  ELEmotionModel.h
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
*  备注：表情数据模型 🐾
*/

#import <UIKit/UIKit.h>

@interface ELEmotionModel : UIView

/// 名称（ 如：[大笑] ）
@property (nonatomic, copy) NSString *name;
/// 编码
@property (nonatomic, copy) NSString *code;

@end
