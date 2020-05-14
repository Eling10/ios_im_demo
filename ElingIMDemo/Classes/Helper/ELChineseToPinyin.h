//
//  ELChineseToPinyin.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELChineseToPinyin : NSObject

/// 从中文中获取拼音
+ (NSString *)pinyinFromChineseString:(NSString *)string;
/// 排序
+ (char)sortSectionTitle:(NSString *)string;

@end
