//
//  ELCoreTextResult.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 文本中链接的类型
typedef NS_ENUM(NSUInteger, ELCoreTextLinkType) {
    // 网址
    ELCoreTextLinkTypeWebsite   =   0,
    // 手机号
    ELCoreTextLinkTypeMobile,
    // 邮箱
    ELCoreTextLinkTypeEmail
};


/*
 *  文本中链接数据模型
 */
@interface ELCoreTextLink : NSObject
/// 链接内容
@property (nonatomic, copy) NSString *content;
/// 链接范围
@property (nonatomic, assign) NSRange range;
/// 矩形框数组
@property (nonatomic, strong) NSArray<UITextSelectionRect *> *rects;
/// 链接类型
@property (nonatomic, assign) ELCoreTextLinkType linkType;
/// 点击背景颜色
@property (nonatomic, strong) UIColor *clickBackgroundColor;
/// 点击的字体大小
@property (nonatomic, strong) UIFont *clickFont;
@end


/*
 * 文本数据模型
 */
@interface ELCoreTextResult : NSObject

/// 文字
@property (nonatomic, strong) NSString *string;
/// 文字范围
@property (nonatomic, assign) NSRange range;
/// 是否是表情
@property (nonatomic, assign) BOOL isEmotion;
/// 每个结果里包含的链接
@property (nonatomic, strong) NSArray<ELCoreTextLink *> *links;

@end
