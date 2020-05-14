//
//  ELCoreTextConst.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELCoreTextConst : NSObject

/// 匹配表情
extern NSString * const ELCoreTextEmotionRegex;
/// 匹配链接
extern NSString * const ELCoreTextLinkRegex;
/// 匹配手机号
extern NSString * const ELCoreTextMobileRegex;
/// 匹配邮箱
extern NSString * const ELCoreTextEmailRegex;

/// 匹配链接属性的 key
extern NSString * const ELCoreTextLinkAttributeKey;
/// 当前覆盖的那个链接
extern NSInteger const ELCoreTextLinkCoverTag;

@end

NS_ASSUME_NONNULL_END
