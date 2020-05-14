//
//  ELCoreTextResultHelper.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELCoreTextResult.h"

@interface ELCoreTextResultHelper : NSObject

/// 将 text 文本转化为处理后的结果集
+ (NSMutableArray<ELCoreTextResult *> *)resultsWithText:(NSString *)text;

@end
