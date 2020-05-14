//
//  ElingIMDemoHeader.h
//  ElingIMDemo
//
//  Created by 樊小聪 on 2020/5/13.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <ElingIM/ELClient.h>

#ifndef ElingIMDemoHeader_h
#define ElingIMDemoHeader_h


/// 用户ID
#define AppID       @"20200409140554243"
/// 用户Secret
#define AppScret    @"6d63f338ac6870a0c153a0643de5dea4"



// 本地环境地址
//#define HOST_URL    @"192.168.1.25"
//#define BASE_URL    [NSString stringWithFormat:@"http://%@:%@/", HOST_URL, @"8081"]
#define HOST_URL    @"203.195.169.217"
#define BASE_URL    [NSString stringWithFormat:@"http://%@:%@/", HOST_URL, @"81"]

#define ACTION_URL   @"api/"

// 接口请求总地址
#define SERVICE_URL   [NSString stringWithFormat:@"%@%@", BASE_URL, ACTION_URL]


#define IM_HOST_URL    @"203.195.169.217"
//#define IM_HOST_URL    @"47.112.47.122"

#pragma mark - 👀 starRTC 👀 💤

// 消息服务
#define IM_URL           [NSString stringWithFormat:@"%@:%@", IM_HOST_URL, @"19903"]
// 聊天室服务
#define CHAT_ROOM_URL    [NSString stringWithFormat:@"%@:%@", IM_HOST_URL, @"19906"]
// voip服务
#define VOIP_URL         [NSString stringWithFormat:@"%@:%@", IM_HOST_URL, @"10086"]




#endif /* ElingIMDemoHeader_h */
