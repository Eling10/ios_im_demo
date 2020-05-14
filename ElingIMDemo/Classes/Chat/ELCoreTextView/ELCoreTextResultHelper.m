//
//  ELCoreTextResultHelper.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELCoreTextResultHelper.h"
#import "ELCoreTextConst.h"
#import <XCMacros/XCMacros.h>

@implementation ELCoreTextResultHelper

+ (NSMutableArray<ELCoreTextResult *> *)resultsWithText:(NSString *)text
{
    // 获取 Emotion 结果集
    NSArray<ELCoreTextResult *> *emotionResults = [self getEmotionResults:text];
    if (!emotionResults.count) {
        // 直接返回正常文本集合
        return [NSMutableArray arrayWithObject:[self getNormalResult:NSMakeRange(0, text.length) string:text]];
    }
    // 返回所有结果集
    return [NSMutableArray arrayWithArray:[self getResultsWithEmotionResults:emotionResults text:text]];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *   获取所有结果集
 *
 *  @param emotionResults emotion结果集
 *  @param text 原始文本
 */
+ (NSArray<ELCoreTextResult *> *)getResultsWithEmotionResults:(NSArray<ELCoreTextResult *> *)emotionResults
                                                         text:(NSString *)text
{
    NSMutableArray<ELCoreTextResult *> *results = [NSMutableArray array];
    
    // 将 emtion 集合添加到数组中
    [results addObjectsFromArray:emotionResults];
    @weakify(self);
    [emotionResults enumerateObjectsUsingBlock:^(ELCoreTextResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        // 设置属性值
        obj.string = [text substringWithRange:obj.range];
        
        if (emotionResults.count == 1) {    // 只有一个表情
            // 普通文本数组
            NSArray *normals = [text componentsSeparatedByString:obj.string];
            if (!normals.count)    { return; }
            if ([normals.firstObject length]) { // 前半部
                ELCoreTextResult *firstNormalResult = [self getNormalResult:[text rangeOfString:normals.firstObject] string:text];
                [results insertObject:firstNormalResult atIndex:0];
            }
            if ([normals.lastObject length]) {  // 后半部
                ELCoreTextResult *lastNormalResult = [self getNormalResult:[text rangeOfString:normals.lastObject] string:text];
                [results addObject:lastNormalResult];
            }
            return;
        }
        
        if (0 == idx) {  // 第一个普通文本
            ELCoreTextResult *firstNormalResult = [self getLastNormalResultWithEmotionResult:obj text:text];
            if (firstNormalResult) {
                [results insertObject:firstNormalResult atIndex:idx];
            }
        } else if (idx == emotionResults.count - 1) {   // 最后一个普通文本
            ELCoreTextResult *lastNormalResult = [self getLastNormalResultWithEmotionResult:obj text:text];
            if (lastNormalResult) {
                [results addObject:lastNormalResult];
            }
        } else {  // 中间的普通文本
            ELCoreTextResult *middleNormalResult = [self getMiddleNormalResultWithEmotionResults:emotionResults index:idx text:text];
            [results insertObject:middleNormalResult atIndex:[results indexOfObject:obj]];
        }
    }];
    
    return results;
}

/**
 *  根据 emotionResult 的数据从 text 中找到前半部的普通文本集
 *
 *  @param emotionResult 表情结果
 */
+ (ELCoreTextResult *)getFirstNormalResultWithEmotionResult:(ELCoreTextResult *)emotionResult
                                                       text:(NSString *)text
{
    NSRange range = NSMakeRange(0, emotionResult.range.location);
    if (emotionResult.range.location != 0) { // 不是从0开始,剪切之前的文本
        return [self getNormalResult:range string:text];
    }
    return nil;
}

/**
 *  根据 emotionResult 的数据从 text 中找到后半部的普通文本集
 *
 *  @param emotionResult 表情结果
 */
+ (ELCoreTextResult *)getLastNormalResultWithEmotionResult:(ELCoreTextResult *)emotionResult
                                                      text:(NSString *)text
{
    NSInteger location = emotionResult.range.location + emotionResult.range.length;
    if (emotionResult.range.location + emotionResult.range.length < text.length) {
        NSRange range = NSMakeRange(location, text.length - location);
        return [self getNormalResult:range string:text];
    }
    return nil;
}

/**
 *  获取除开最前面部分和最后部分的普通文本
 *
 *  @param emotionResults emotion结果结果集
 *  @param index 索引
 */
+ (ELCoreTextResult *)getMiddleNormalResultWithEmotionResults:(NSArray<ELCoreTextResult *> *)emotionResults
                                                        index:(NSInteger)index
                                                         text:(NSString *)text
{
    ELCoreTextResult *result    = emotionResults[index];
    NSInteger currentLocation   = result.range.location;
    //前一个location
    ELCoreTextResult *preResult = emotionResults[index - 1];
    NSInteger preLocation       = preResult.range.location;
    NSInteger preLength         = preResult.range.length;
    //获取文本
    NSInteger length            = currentLocation - preLocation - preLength;
    NSInteger location          = preLocation + preResult.range.length;
    
    if (length) {
        return [self getNormalResult:NSMakeRange(location, length) string:text];
    }
    return nil;
}

/**
 *  获取所有有序表情集
 */
+ (NSArray<ELCoreTextResult *> *)getEmotionResults:(NSString *)text
{
    // 匹配表情
    NSMutableArray<ELCoreTextResult *> *emotionResults = [NSMutableArray array];
    //正则匹配表情
    NSError *error = nil;
    NSRegularExpression *emotionExpression = [NSRegularExpression regularExpressionWithPattern:ELCoreTextEmotionRegex options:NSRegularExpressionCaseInsensitive error:&error];
    [emotionExpression enumerateMatchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.length) {
            ELCoreTextResult *emotionResult = [ELCoreTextResult new];
            emotionResult.isEmotion = YES;
            emotionResult.range     = result.range;
            [emotionResults addObject:emotionResult];
        }
    }];
    
    //表情结果集排序
    [emotionResults sortUsingComparator:^NSComparisonResult(ELCoreTextResult *_Nonnull result1, ELCoreTextResult  *_Nonnull result2) {
        return result1.range.location > result2.range.location;
    }];
    return emotionResults;
}

/**
 *  处理非表情字符集
 *
 *  @param range 范围
 */
+ (ELCoreTextResult *)getNormalResult:(NSRange)range string:(NSString *)text
{
    ELCoreTextResult *normalResult = [ELCoreTextResult new];
    normalResult.range = range;
    normalResult.string = [text substringWithRange:range];
    normalResult.isEmotion = NO;
    
    NSMutableArray *links = [NSMutableArray array];
    // 网址
    [links addObjectsFromArray:[self getLinksWithLinkType:ELCoreTextLinkTypeWebsite string:normalResult.string]];
    
    // 邮箱
    [links addObjectsFromArray:[self getLinksWithLinkType:ELCoreTextLinkTypeEmail string:normalResult.string]];

    // 手机号
    [links addObjectsFromArray:[self getLinksWithLinkType:ELCoreTextLinkTypeMobile string:normalResult.string]];

    return normalResult;
}

/**
 *  获取普通文本中的 link 结果集
 *
 *  @param linkType 链接类型
 */
+ (NSArray<ELCoreTextLink *> *)getLinksWithLinkType:(ELCoreTextLinkType)linkType
                                             string:(NSString *)string
{
    NSMutableArray *links = [NSMutableArray array];
    // 匹配的正则
    NSString *linkRegex;
    switch (linkType) {
        case ELCoreTextLinkTypeWebsite: // 网址
            linkRegex = ELCoreTextLinkRegex;
            break;
        case ELCoreTextLinkTypeEmail:   // 邮箱
            linkRegex = ELCoreTextEmailRegex;
            break;
        case ELCoreTextLinkTypeMobile:  // 手机号
            linkRegex = ELCoreTextMobileRegex;
            break;
    }
    NSRegularExpression *linkExpression = [NSRegularExpression regularExpressionWithPattern:linkRegex options:NSRegularExpressionCaseInsensitive error:nil];
    //遍历结果
    [linkExpression enumerateMatchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
       if (result.range.length) {
           ELCoreTextLink *link = [ELCoreTextLink new];
           link.range    = result.range;
           link.content = [string substringWithRange:result.range];
           link.linkType = linkType;
           [links addObject:link];
       }
    }];
    return links;
}

@end
