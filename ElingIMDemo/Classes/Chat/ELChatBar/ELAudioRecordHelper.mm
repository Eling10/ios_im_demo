//
//  ELAudioRecordHelper.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/14.
//  Copyright © 2020 Parkin. All rights reserved.
//

/*
*  备注：录音工具类 🐾
*/

#import <AVFoundation/AVFoundation.h>
#import "ELAudioRecordHelper.h"
#import "amrFileCodec.h"

@interface ELAudioRecordHelper()<AVAudioRecorderDelegate>

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDictionary *recordSetting;

@property (nonatomic, copy) void (^recordFinished)(NSString *aPath, NSInteger aTimeLength);

@end


@implementation ELAudioRecordHelper

static ELAudioRecordHelper *_recordHelper = nil;

- (void)dealloc
{
    [self _stopRecord];
}

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _recordHelper = [[ELAudioRecordHelper alloc] init];
    });
    return _recordHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recordSetting = @{AVSampleRateKey:@(8000.0), AVFormatIDKey:@(kAudioFormatLinearPCM), AVLinearPCMBitDepthKey:@(16), AVNumberOfChannelsKey:@(1), AVEncoderAudioQualityKey:@(AVAudioQualityHigh)};
    }
    return self;
}


#pragma mark - Private

+ (int)wavPath:(NSString *)aWavPath toAmrPath:(NSString*)aAmrPath
{
    if (EM_EncodeWAVEFileToAMRFile([aWavPath cStringUsingEncoding:NSASCIIStringEncoding], [aAmrPath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;   // success
    
    return 1;   // failed
}

/**
 *  将 wav 音频格式转化为 amr 音频格式
 *
 *  @param aWavPath wav音频路径
 *  @param aAmrPath amr音频路径
 */
- (BOOL)_convertWAV:(NSString *)aWavPath toAMR:(NSString *)aAmrPath
{
    BOOL ret = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:aAmrPath]) {
        ret = YES;
    } else if ([fileManager fileExistsAtPath:aWavPath]) {
        [ELAudioRecordHelper wavPath:aWavPath toAmrPath:aAmrPath];
        if ([fileManager fileExistsAtPath:aAmrPath]) {
            ret = YES;
        }
    }
    return ret;
}

#pragma mark - Private

- (void)_stopRecord
{
    _recorder.delegate = nil;
    if (_recorder.recording) {
        [_recorder stop];
    }
    _recorder = nil;
    self.recordFinished = nil;
}

#pragma mark - Public

- (void)startRecordWithPath:(NSString *)aPath
                 completion:(void(^)(NSError *error))aCompletion
{
    NSError *error = nil;
    do {
        if (self.recorder && self.recorder.isRecording) {
            error = [NSError errorWithDomain:@"正在进行录制" code:-1 userInfo:nil];
            break;
        }
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
        if (!error){
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
        }
        
        if (error) {
            error = [NSError errorWithDomain:@"AVAudioSession SetCategory失败" code:-1 userInfo:nil];
            break;
        }
        
        NSString *wavPath = [[aPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
        NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavPath];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:wavUrl settings:self.recordSetting error:&error];
        if(error || !self.recorder) {
            self.recorder = nil;
            error = [NSError errorWithDomain:@"文件格式转换失败" code:-1 userInfo:nil];
            break;
        }
        
        BOOL ret = [self.recorder prepareToRecord];
        if (ret) {
            self.startDate = [NSDate date];
            self.recorder.meteringEnabled = YES;
            self.recorder.delegate = self;
            ret = [self.recorder record];
        }
        
        if (!ret) {
            [self _stopRecord];
            error = [NSError errorWithDomain:@"准备录制工作失败" code:-1 userInfo:nil];
        }
        
    } while (0);
    
    if (aCompletion) {
        aCompletion(error);
    }
}

- (void)stopRecordWithCompletion:(void(^)(NSString *aPath, NSInteger aTimeLength))aCompletion
{
    self.recordFinished = aCompletion;
    [self.recorder stop];
}

- (void)cancelRecord
{
    [self _stopRecord];
    self.startDate = nil;
    self.endDate = nil;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    NSInteger timeLength = [[NSDate date] timeIntervalSinceDate:self.startDate];
    NSString *recordPath = [[self.recorder url] path];
    if (self.recordFinished) {
        if (!flag) {
            recordPath = nil;
        }
        // Convert wav to amr
        NSString *amrFilePath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
        BOOL ret = [self _convertWAV:recordPath toAMR:amrFilePath];
        if (ret) {
            // Remove the wav
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:recordPath error:nil];
            
            amrFilePath = amrFilePath;
        } else {
            recordPath = nil;
            timeLength = 0;
        }
        self.recordFinished(amrFilePath, timeLength);
    }
    self.recorder = nil;
    self.recordFinished = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error
{
}

@end
