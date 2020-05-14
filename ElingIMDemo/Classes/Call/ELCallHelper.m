//
//  ELCallHelper.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELCallHelper.h"

#import "ELUtilMacros.h"

#import "EL1v1CallViewController.h"
#import "EL1v1AudioViewController.h"
#import "EL1v1VideoViewController.h"

#import <ElingIM/ELClient.h>
#import <XCMacros/XCMacros.h>
#import <XCProgressHUD/UIView+XCProgressHUD.h>

// 标记是否有通话正在进行
BOOL gIsCalling = NO;

static ELCallHelper *callManager = nil;

@interface ELCallHelper()<ELCallManagerDelegate>

@property (strong, nonatomic) NSObject *callLock;
@property (strong, nonatomic) ELMessage *currentCall;
@property (nonatomic, strong) EL1v1CallViewController *currentController;

@property (strong, nonatomic) NSTimer *timeoutTimer;

@end


@implementation ELCallHelper

- (void)dealloc
{
    [[ELClient sharedClient].callManager removeDelegate:self];
}

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callManager = [[ELCallHelper alloc] init];
    });
    
    return callManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentCall = nil;
    _currentController = nil;

    // 添加代理
    [[ELClient sharedClient].callManager addDelegate:self];
}

/**
 *  结束通话
 *
 *  @param aCallId 通话ID
 */
- (void)_endCall:(NSString *)aCallId
{
    if (!self.currentCall || ![self.currentCall.conversationId isEqualToString:aCallId]) {
        return;
    }
    gIsCalling = NO;
    [self _stopCallTimeoutTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    @synchronized (_callLock) {
        self.currentCall = nil;
        [self.currentController clearDataAndView];
        [self.currentController dismissViewControllerAnimated:NO completion:nil];
        self.currentController = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];
    }
}

/// 显示提示框
- (void)_showHUD:(NSString *)hud
{
    [[UIApplication sharedApplication].keyWindow showText:hud];
}

/**
 *  超时未响应
 */
- (void)_timeoutBeforeCallAnswered
{
    // 主动结束呼叫
    [[ELClient sharedClient].callManager cancel:self.currentCall.conversationId completion:nil];
    [self _endCall:self.currentCall.conversationId];
    [self _showHUD:@"没有响应"];
}

/**
 *  开启定时器
 */
- (void)_startCallTimeoutTimer
{
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
}

/**
 *  关闭定时器
 */
- (void)_stopCallTimeoutTimer
{
    if (self.timeoutTimer == nil) {
        return;
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)callTo:(NSString *)callId
      callType:(ELCallType)callType
{
    if (!callId || ![callId length])    return;

    if (gIsCalling) {
        [self _showHUD:@"有通话正在进行"];
        return;
    }
      
    @weakify(self);
    void (^completionBlock)(ELMessage *, NSError *) = ^(ELMessage *aCallSession, NSError *aError) {
        @strongify(self);
        if (self) {
            if (aError || aCallSession == nil) {
                gIsCalling = NO;
                [self _showHUD:@"呼叫失败"];
                return;
            }
            @synchronized (self.callLock) {
                self.currentCall = aCallSession;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.currentController.callSession = self.currentCall;
                });
            }
            [self _startCallTimeoutTimer];
        } else {
            gIsCalling = NO;
            [[ELClient sharedClient].callManager cancel:aCallSession.conversationId completion:nil];
        }
    };
    
    if (callType == ELCallTypeVideo) {
        self.currentController = [[EL1v1VideoViewController alloc] init];
    } else {
        self.currentController = [[EL1v1AudioViewController alloc] init];
    }
      
    gIsCalling = YES;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootViewController presentViewController:self.currentController animated:NO completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ELClient sharedClient].callManager call:callId type:callType completion:completionBlock];
    });
}

- (void)acceptCall:(NSString *)aCallId
{
    if (!self.currentCall || ![self.currentCall.conversationId isEqualToString:aCallId]) {
        return ;
    }
    
    @weakify(self);
    [[ELClient sharedClient].callManager accept:aCallId completion:^(NSError *error) {
        @strongify(self);
        if (error) {
            [[ELClient sharedClient].callManager refuse:aCallId completion:nil];
            [self _endCall:aCallId];
            [self _showHUD:@"连接失败"];
        }
    }];
}

- (void)endCall:(NSString *)aCallId isCaller:(BOOL)isCaller reason:(ELCallEndReason)reason;
{
    if (reason == ELCallEndReasonHangup) {   // 挂断
        [[ELClient sharedClient].callManager hangup:aCallId completion:nil];
    } else {
        [self _endCall:aCallId];
        if (isCaller) { // 主动取消
            [[ELClient sharedClient].callManager cancel:aCallId completion:nil];
        } else { // 拒绝接收
            [[ELClient sharedClient].callManager refuse:aCallId completion:nil];
        }
    }
}

#pragma mark - 👀 ELCallManagerDelegate 👀 💤

/**
 *  收到呼叫
 */
- (void)callDidReceive:(ELMessage *)aSession
{
    if (!aSession || [aSession.conversationId length] == 0) {
        return;
    }
    if(gIsCalling || (self.currentCall && self.currentCall.status != ELCallSessionStatusDisconnected)){
        [[ELClient sharedClient].callManager refuse:aSession.conversationId completion:nil];
        return;
    }
    
    gIsCalling = YES;
    @synchronized (self->_callLock) {
        // 开始计时
        [self _startCallTimeoutTimer];
        self.currentCall = aSession;
        if (aSession.body.type == ELMessageBodyTypeAudioCall) {
            self.currentController =[[EL1v1AudioViewController alloc] init];
        } else {
            self.currentController = [[EL1v1VideoViewController alloc] init];
        }
        self.currentController.callSession = self.currentCall;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentController) {
                self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIViewController *rootViewController = window.rootViewController;
                [rootViewController presentViewController:self.currentController animated:NO completion:nil];
            }
        });
    }
}

/**
 *  连接成功，双方都会收到此回调
 *
 *  @param aSession 消息对象
 */
- (void)callDidConnect:(ELMessage *)aSession
{
    if ([aSession.conversationId isEqualToString:self.currentCall.conversationId]) {
        [self _stopCallTimeoutTimer];
        self.currentController.callStatus = ELCallSessionStatusConnected;
    }
}

/**
 *  通话关闭，双方都会收到此回调
 *
 *  @param aSession 消息对象
 */
- (void)callDidEnd:(ELMessage *)aSession
{
    NSString *callId = self.currentCall.conversationId;
    [self _endCall:aSession.conversationId];
    if (![aSession.conversationId isEqualToString:callId]) {
        return;
    }
    ELCallMessageBody *body = (ELCallMessageBody *)aSession.body;
    NSString *reasonStr = @"通话已结束";
    switch (body.reason) {
        case ELCallEndReasonHangup: {
            reasonStr = @"通话已结束";
            // 发出通知，更新消息、聊天列表
            [NOTIFICATION_CENTER postNotificationName:ELCALL_END object:aSession];
            break;
        }
        case ELCallEndReasonCancel:
            reasonStr = @"对方已取消";
            break;
        case ELCallEndReasonBusy:
            reasonStr = @"对方正在通话中";
            break;
        case ELCallEndReasonFailed:
            reasonStr = @"连接失败";
            break;
        default:
            break;
    }
    [self _showHUD:reasonStr];
}

@end
