//
//  ELDateHelper.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/22.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE    60
#define D_HOUR      3600
#define D_DAY       86400
#define D_WEEK      604800
#define D_YEAR      31556926


@interface ELDateHelper : NSObject

/**
 *  将毫秒转化为日期对象
 *
 *  @param aMilliSecond 毫秒
 */
+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)aMilliSecond;

/**
 *  将秒转化为时间字符串
 *
 *  @param aTimeInterval 时间字符串
 */
+ (NSString *)formattedTimeFromTimeInterval:(long long)aTimeInterval;

/**
 *  格式化日期
 */
+ (NSString *)formattedTime:(NSDate *)aDate;

@end
