//
//  ELWaveView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/5/7.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELWaveView.h"
#import <XCCategory/UIView+XCExtension.h>


#define kWaveHeight     4

@interface ELWaveView ()

/// 定时器
@property (nonatomic, strong) CADisplayLink *timer;
/// 时浪图层
@property (nonatomic, strong) CAShapeLayer *realWaveLayer;
/// 遮罩浪图层
@property (nonatomic, strong) CAShapeLayer *maskWaveLayer;

@end

@implementation ELWaveView
{
    CGFloat _offset;    // 记录偏移量
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置 UI
        [self setupUI];
    }
    return self;
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.waveColor = [UIColor whiteColor];
    self.maskWaveColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    
    [self.layer addSublayer:self.realWaveLayer];
    [self.layer addSublayer:self.maskWaveLayer];
}

#pragma mark - 💤 👀 LazyLoad Method 👀

- (CAShapeLayer *)realWaveLayer
{
    if (!_realWaveLayer) {
        _realWaveLayer = [CAShapeLayer layer];
        CGRect frame = self.bounds;
        frame.origin.y = frame.size.height-kWaveHeight;
        frame.size.height = kWaveHeight;
        _realWaveLayer.frame = frame;
        _realWaveLayer.fillColor = self.waveColor.CGColor;
    }
    return _realWaveLayer;
}

- (CAShapeLayer *)maskWaveLayer
{
    if (!_maskWaveLayer) {
         _maskWaveLayer = [CAShapeLayer layer];
        CGRect frame = self.bounds;
        frame.origin.y = frame.size.height-kWaveHeight;
        frame.size.height = kWaveHeight;
        _maskWaveLayer.frame = frame;
        _maskWaveLayer.fillColor = self.maskWaveColor.CGColor;
    }
    return _maskWaveLayer;
}

#pragma mark - 🔒 👀 Privite Method 👀

- (void)wave
{
    CGFloat waveCurvature = 1.5;    // 浪弯曲度
    _offset += 0.5;
    
    // 获取宽,高
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = kWaveHeight;
    
    // 真实波浪
    CGMutablePathRef realpath = CGPathCreateMutable();
    CGPathMoveToPoint(realpath, NULL, 0, height);
    CGFloat realY = 0.f;
    
    // 遮罩波浪
    CGMutablePathRef maskpath = CGPathCreateMutable();
    CGPathMoveToPoint(maskpath, NULL, 0, height);
    CGFloat maskY = 0.f;
    
    for (CGFloat x = 0.f; x <= width; x++) {
        realY = height * sinf(0.01 * waveCurvature * x + _offset * 0.045);
        CGPathAddLineToPoint(realpath, NULL, x, realY);
        maskY = -realY;
        CGPathAddLineToPoint(maskpath, NULL, x, maskY);
    }
    
    // 真实波浪
    CGPathAddLineToPoint(realpath, NULL, width, height);
    CGPathAddLineToPoint(realpath, NULL, 0, height);
    CGPathCloseSubpath(realpath);
    
    // 描述路径后利用CAShapeLayer类绘制不规则图形
    self.realWaveLayer.path = realpath;
    self.realWaveLayer.fillColor = self.waveColor.CGColor;
    CGPathRelease(realpath);
    
    // 遮罩波浪
    CGPathAddLineToPoint(maskpath, NULL, width, height);
    CGPathAddLineToPoint(maskpath, NULL, 0, height);
    CGPathCloseSubpath(maskpath);
    
    // 描述路径后利用CAShapeLayer类绘制不规则图形
    self.maskWaveLayer.path = maskpath;
    self.maskWaveLayer.fillColor = self.maskWaveColor.CGColor;
    CGPathRelease(maskpath);
}


#pragma mark - 🔓 👀 Public Method 👀

- (void)startAnimation
{
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(wave)];
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
