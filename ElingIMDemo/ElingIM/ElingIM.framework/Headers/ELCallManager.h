//
//  ELCallManager.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/13.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：音视频通话 🐾
 */

#import <Foundation/Foundation.h>
#import "ELMessage.h"

/**
 *  通话类型
 */
typedef NS_ENUM(NSUInteger, ELCallType){
    /// 语音聊天
    ELCallTypeAudio = 0,
    /// 视频聊天
    ELCallTypeVideo
};

/**
 *  摄像头方向
 */
typedef NS_ENUM(NSUInteger, ELCameraDirection) {
    /// 前置摄像头
    ELCameraDirectionFront  = 0,
    /// 后置摄像头
    ELCameraDirectionBack
};

/**
 *  视频通话分辨率
 */
typedef NS_ENUM(NSUInteger, ELCallVideoResolution) {
    /// 大图：176*320  小图：无
    ELCallVideoResolution_176BW_320BH_SMALL_NONE,
    /// 大图：176*320  小图：88*160
    ELCallVideoResolution_176BW_320BH_88SW_160SH,
    
    /// 大图：240*320  小图：无
    ELCallVideoResolution_240BW_320BH_SMALL_NONE,
    /// 大图：240*320  小图：120*160
    ELCallVideoResolution_240BW_320BH_120SW_160SH,
    
    /// 大图：480*480  小图：无
    ELCallVideoResolution_480BW_480BH_SMALL_NONE,
    /// 大图：480*480  小图：120*120
    ELCallVideoResolution_480BW_480BH_120SW_120SH,
    /// 大图：480*480  小图：240*240
    ELCallVideoResolution_480BW_480BH_240SW_240SH,
    
    /// 大图：360*640  小图：无
    ELCallVideoResolution_360BW_640BH_SMALL_NONE,
    /// 大图：360*640  小图：90*160
    ELCallVideoResolution_360BW_640BH_90SW_160SH,
    /// 大图：360*640  小图：180*320
    ELCallVideoResolution_360BW_640BH_180SW_320SH,
    
    /// 大图：480*640  小图：无
    ELCallVideoResolution_480BW_640BH_SMALL_NONE,
    /// 大图：480*640  小图：120*160
    ELCallVideoResolution_480BW_640BH_120SW_160SH,
    /// 大图：480*640  小图：240*320
    ELCallVideoResolution_480BW_640BH_240SW_320SH,
    
    /// 大图：640*640  小图：无
    ELCallVideoResolution_640BW_640BH_SMALL_NONE,
    /// 大图：640*640  小图：160*160
    ELCallVideoResolution_640BW_640BH_160SW_160SH,
    /// 大图：640*640  小图：320*320
    ELCallVideoResolution_640BW_640BH_320SW_320SH,
    
    /// 大图：720*1280  小图：无
    ELCallVideoResolution_720BW_1280BH_SMALL_NONE,
    /// 大图：720*1280  小图：90*160
    ELCallVideoResolution_720BW_1280BH_90SW_160SH,
    /// 大图：720*1280   小图：180*320
    ELCallVideoResolution_720BW_1280BH_180SW_320SH,
    /// 大图：720*1280   小图：360*640
    ELCallVideoResolution_720BW_1280BH_360SW_640SH,
    
    /// 大图：1080*1920  小图：无
    ELCallVideoResolution_1080BW_1920BH_SMALL_NONE,
    /// 大图：1080*1920   小图：135*240
    ELCallVideoResolution_1080BW_1920BH_135SW_240SH,
    /// 大图：1080*1920   小图：270*480
    ELCallVideoResolution_1080BW_1920BH_270SW_480SH,
    /// 大图：1080*1920   小图：540*960
    ELCallVideoResolution_1080BW_1920BH_540SW_960SH,
    
    /// 大图：特殊定制 小图：无
    ELCallVideoResolution_BIG_NOCROP_SMALL_NONE
};

/**
 *  视频编码格式配置
 */
typedef NS_ENUM(NSUInteger, ELCallVideoCodecType) {
    ELCallVideoCodecTypeH264,
    ELCallVideoCodecTypeH265,
    ELCallVideoCodecTypeMPEG1
};

/**
 *  音频编码格式配置
 */
typedef NS_ENUM(NSUInteger, ELCallAudioCodecType) {
    ELCallAudioCodecTypeOPUS,
    ELCallAudioCodecTypeAAC,
    ELCallAudioCodecTypeMP2
};


/**
 *  通话配置类
 */
@interface ELCallOptions : NSObject

/// 是否使用openGL渲染，默认 YES
@property (nonatomic, assign) BOOL openGLEnable;
/// 是否使用硬编码，默认 NO
@property (nonatomic, assign) BOOL hwEncodeEnable;
/// 是否动态调节帧率码率，默认 NO
@property (nonatomic, assign) BOOL dynamicBitrateAndFPSEnable;
/// 大图码率，默认 500
@property (nonatomic, assign) int bigVideoBitrate;
/// 大图帧率，默认 15
@property (nonatomic, assign) int bigVideoFPS;
/// 小图码率，默认 100
@property (nonatomic, assign) int smallVideoBitrate;
/// 小图帧率，默认 15
@property (nonatomic, assign) int smallVideoFPS;
/// 视频分辨率，默认 ELCallVideoResolution_360BW_640BH_180SW_320SH
@property (nonatomic, assign) ELCallVideoResolution resolution;
/// 视频编码格式配置，默认 ELCallVideoCodecTypeH264
@property (nonatomic, assign) ELCallVideoCodecType videoCodecType;
/// 音频编码格式配置，默认 ELCallAudioCodecTypeAAC
@property (nonatomic, assign) ELCallAudioCodecType audioCodecType;

/**
 *  配置配置
 */
+ (instancetype)defaultOptions;

@end



@protocol ELCallManagerDelegate <NSObject>

@optional
/**
 *  用户A拨打用户B，用户B会收到这个回调
 *
 *  @param aMessage 消息对象
 */
- (void)callDidReceive:(ELMessage *)aMessage;

/**
 *  连接成功，双方都会收到此回调
 *
 *  @param aMessage 消息对象
 */
- (void)callDidConnect:(ELMessage *)aMessage;

/**
 *  通话关闭，双方都会收到此回调
 *
 *  @param aMessage 消息对象
 */
- (void)callDidEnd:(ELMessage *)aMessage;

/**
 *  收到实时数据流，此方法会调用多次
 *
 *  @param data 二进制流
 */
- (void)onReceiveRealtimeData:(NSData *)data;

@end



@interface ELCallManager : NSObject

/// 添加代理
- (void)addDelegate:(id<ELCallManagerDelegate>)delegate;
/// 移除代理
- (void)removeDelegate:(id<ELCallManagerDelegate>)delegate;

/// 切换摄像头方向，返回切换后的摄像头方向
- (ELCameraDirection)switchCamera;

/// 开关音频
- (void)setAudioEnable:(BOOL)enable;

/// 开关视频
- (void)setVideoEnable:(BOOL)enable;

/// 设置主方和对方的视频画面
- (void)setupView:(UIView *)selfPreview targetView:(UIView *)targetView;

/// 配置通话项
- (void)setCallOptions:(ELCallOptions *)options;

#pragma mark - 👀 主叫方调用 👀 💤

/**
 *  发起音视频通话
 *
 *  @param toId 接收人ID
 *  @param type 通话类型
 *  @param aCompletionBlock 回调
 */
- (void)call:(NSString *)toId
        type:(ELCallType)type
  completion:(void(^)(ELMessage *callSession, NSError *error))aCompletionBlock;

/**
 *  取消通话
 *
 *  @param toId 接收人ID
 */
- (void)cancel:(NSString *)toId
    completion:(void(^)(NSError *error))aCompletionBlock;

#pragma mark - 👀 被叫方调用 👀 💤

/**
 *  同意通话
 *
 *  @param fromId 拨叫方ID
 */
- (void)accept:(NSString *)fromId
    completion:(void(^)(NSError *error))aCompletionBlock;

/**
 *  拒绝通话
 *
 *  @param fromId 拨叫方ID
 */
- (void)refuse:(NSString *)fromId
    completion:(void(^)(NSError *error))aCompletionBlock;


#pragma mark - 👀 双方 👀 💤

/**
 *  挂断
 *
 *  @param callId 通话ID
 */
- (void)hangup:(NSString *)callId
    completion:(void(^)(NSError *error))completion;

@end
