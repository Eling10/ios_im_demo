//
//  ELCoreTextConst.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELCoreTextConst.h"

@implementation ELCoreTextConst

NSString * const ELCoreTextEmotionRegex = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";
NSString * const ELCoreTextLinkRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
NSString * const ELCoreTextMobileRegex = @"((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[57])|(17[013678]))\\d{8}";
NSString * const ELCoreTextEmailRegex = @"[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+";

NSString * const ELCoreTextLinkAttributeKey = @"ELCoreTextLinkAttributeKey";
NSInteger const ELCoreTextLinkCoverTag = 888;

@end
