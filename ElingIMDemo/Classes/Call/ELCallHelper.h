//
//  ELCallHelper.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ElingIM.h"

@interface ELCallHelper : NSObject

+ (instancetype)sharedHelper;

/**
 *  发起音视频通话
 *
 *  @param callId 会话ID
 *  @param callType 会话类型
 */
- (void)callTo:(NSString *)callId
      callType:(ELCallType)callType;
/**
 *  同意接听
 *
 *  @param aCallId 会话ID
 */
- (void)acceptCall:(NSString *)aCallId;

/**
 *  结束通话
 *
 *  @param aCallId 会话ID
 *  @param isCaller 是否是主叫方
 *  @param reason 结束原因（取消、拒绝、挂断）
 */
- (void)endCall:(NSString *)aCallId
       isCaller:(BOOL)isCaller
         reason:(ELCallEndReason)reason;
@end
