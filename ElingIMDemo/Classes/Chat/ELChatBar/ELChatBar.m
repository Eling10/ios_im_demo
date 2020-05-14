//
//  ELChatBar.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/12.
//  Copyright © 2020 Parkin. All rights reserved.
// 

#import "ELChatBar.h"
#import "ELChatBarConst.h"
#import "ELEmotionView.h"
#import "ELEmotionModel.h"
#import "ELAudioRecordView.h"
#import "NSString+Emoji.h"

#import <XCMacros/XCMacros.h>
#import <XCCategory/UIImage+XCExtension.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>

typedef NS_ENUM(NSInteger, ELChatBarStatus) {
    /// 默认状态，键盘未升起
    ELChatBarStatusDefault = 0,
    /// 系统键盘
    ELChatBarStatusSystemKeyboard,
    /// 录音状态
    ELChatBarStatusRecord,
    /// 表情页面
    ELChatBarStatusEmotion,
    /// 显示 “更多” 页面状态
    ELChatBarStatusMore
};

@interface ELChatBar ()<UITextViewDelegate>

/// 聊天栏的状态
@property (assign, nonatomic) ELChatBarStatus status;

/// bar容器视图
@property (strong, nonatomic) UIView *barContainer;
/// 键盘视图
@property (strong, nonatomic) UIView *keyboardContainer;
/// bar顶部的分隔线
@property(nonatomic,strong) UIView *barTopLine;
/// 键盘视图上的分隔线
@property(nonatomic,strong) UIView *keyboardTopLine;

/// 表情视图
@property (strong, nonatomic) ELEmotionView *emotionView;

/// 语音按钮
@property (nonatomic, strong) UIButton *audioButton;
/// 长按说话按钮
@property (nonatomic, strong) UIButton *audioLpButton;
/// 表情按钮
@property (nonatomic, strong) UIButton *emotionButton;
/// 更多按钮
@property (nonatomic, strong) UIButton *moreButton;
/// 输入框
@property (nonatomic, strong) UITextView *inputField;

/// 录音视图
@property (strong, nonatomic) ELAudioRecordView *audioRecordView;

@end


@implementation ELChatBar
{
    /// 记录当前键盘的高度
    CGFloat _keyboardHeight;
    /// 底部的安全距离
    CGFloat _safeAreaBottom;
    /// 动画时间
    NSTimeInterval _duration;
}

- (void)dealloc
{
    /// 移除通知
    [self removeNotification];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        /// 设置UI
        [self setupUI];
        /// 添加 通知
        [self registerNotification];
    }
    return self;
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    _keyboardHeight = ELEmotionKeyboardHeight;  // 默认是表情键盘的高度
    
    // 添加子视图
    [self addSubview:self.barContainer];
    [self addSubview:self.keyboardContainer];
    
    // bar
    [self.barContainer addSubview:self.barTopLine];
    [self.barContainer addSubview:self.audioButton];
    [self.barContainer addSubview:self.audioLpButton];
    [self.barContainer addSubview:self.inputField];
    [self.barContainer addSubview:self.emotionButton];
    [self.barContainer addSubview:self.moreButton];
    
    // keyboard
    [self.keyboardContainer addSubview:self.emotionView];
    // 更多视图
    _moreView = [[UIView alloc] initWithFrame:self.keyboardContainer.bounds];
    _moreView.backgroundColor = self.keyboardContainer.backgroundColor;
    [self.keyboardContainer addSubview:_moreView];
    [self.keyboardContainer addSubview:self.keyboardTopLine];
    
    // 更新UI
    [self refreshUI:YES];
}

#pragma mark - 👀 Notification 👀 💤

/// 注册通知
- (void)registerNotification
{
    /// 键盘相关的通知
    // 系统键盘弹起通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 系统键盘降落
    [NOTIFICATION_CENTER addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    /// 表情相关的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(emotionDidSelected:) name:ELEmotionDidSelectNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(emotionDidDelete:) name:ELEmotionDidDeleteNotification object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(sendMessage) name:ELEmotionDidSendNotification object:nil];
}

/// 移除通知
- (void)removeNotification
{
    [self.inputField removeObserver:self forKeyPath:@"contentSize"];
    [NOTIFICATION_CENTER removeObserver:self];
}

/// 通知事件 --- 表情被选中
- (void)emotionDidSelected:(NSNotification *)notification
{
    // 当表情被选中后，将表情文字查入到输入框内
    ELEmotionModel *emotion = notification.userInfo[ELSelectEmotionKey];
    if (emotion.name) {
        [self.inputField insertText:emotion.name];
    } else {
        [self.inputField insertText:emotion.code.emoji];
    }
}

/// 通知事件 --- 表情被删除
- (void)emotionDidDelete:(NSNotification *)notification
{
    // 删除
    [self delete];
}

/// 通知事件 --- 发送表情
- (void)sendMessage
{
    // 发送
    [self send];
}

/// 通知事件 --- 键盘升起
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.status = ELChatBarStatusSystemKeyboard;
    // 获取键盘高度
    _keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    _duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 更新UI
    [self refreshUI:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarUp)]) {
        [self.delegate chatBarUp];
    }
}

/// 通知事件 --- 键盘降落
- (void)keyboardWillHide
{
    // 隐藏键盘
    _keyboardHeight = ELEmotionKeyboardHeight;
    // 更新UI
    [self refreshUI:NO];
}

#pragma mark - 👀 KVO 👀 💤

/// 监听输入框变化
// 这里用contentSize计算较为简单和精确, 如果计算文字高度 ,  还需要加上textView的内间距.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    CGFloat oldHeight = [change[@"old"] CGSizeValue].height;
    CGFloat newHeight = [change[@"new"] CGSizeValue].height;
    if (oldHeight <= 0 || newHeight <= 0) return;
    if (newHeight != oldHeight) {
        // 根据实时的键盘高度进行布局
        CGFloat inputHeight = newHeight > ELChatBarInputDefaultHeight ? newHeight : ELChatBarInputDefaultHeight;
        [self updateInputFieldHeight:inputHeight];
    }
}

#pragma mark - 🔑 👀 Getter Method 👀

- (UIView *)barContainer
{
    if (!_barContainer) {
        _barContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ELChatBarHeight)];
        _barContainer.backgroundColor = [UIColor whiteColor];
    }
    return _barContainer;
}

- (UIView *)keyboardContainer
{
    if (!_keyboardContainer) {
        _keyboardContainer = [[UIView alloc] initWithFrame:CGRectMake(0, ELChatBarHeight, SCREEN_WIDTH, ELEmotionKeyboardHeight)];
        _keyboardContainer.backgroundColor = [UIColor whiteColor];
    }
    return _keyboardContainer;
}

- (ELEmotionView *)emotionView
{
    if (!_emotionView) {
        _emotionView = [[ELEmotionView alloc] initWithFrame:self.keyboardContainer.bounds];
        _emotionView.backgroundColor = self.keyboardContainer.backgroundColor;
    }
    return _emotionView;
}

- (UIView *)barTopLine
{
    if (!_barTopLine) {
        _barTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, .5f)];
        _barTopLine.backgroundColor = [UIColor colorWithRed:200./255. green:200./255. blue:200./255. alpha:1.];
        _barTopLine.hidden = YES;
    }
    return _barTopLine;
}

- (UIView *)keyboardTopLine
{
    if (!_keyboardTopLine) {
        _keyboardTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, .5f)];
        _keyboardTopLine.backgroundColor = self.barTopLine.backgroundColor;
    }
    return _keyboardTopLine;
}

- (UIButton *)audioButton
{
    if (!_audioButton) {
        _audioButton = [self chatBarButtonWithX:0
                                normalImageName:@"chat_bar_audio"
                              selectedImageName:@"chat_bar_keyboard"
                                    clickAction:@selector(clickAudioButtonAction)];
    }
    return _audioButton;
}

- (UIButton *)emotionButton
{
    if (!_emotionButton) {
        _emotionButton = [self chatBarButtonWithX:(SCREEN_WIDTH - 2 * ELChatBarButtonWidth)
                                  normalImageName:@"chat_bar_emotion"
                                selectedImageName:@"chat_bar_keyboard"
                                      clickAction:@selector(clickEmotionButtonAction)];
    }
    return _emotionButton;
}

- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [self chatBarButtonWithX:(SCREEN_WIDTH - ELChatBarButtonWidth)
                               normalImageName:@"chat_bar_more"
                             selectedImageName:@"chat_bar_more"
                                   clickAction:@selector(clickMoreButtonAction)];
    }
    return _moreButton;
}

- (UITextView *)inputField
{
    if (!_inputField) {
        _inputField = [[UITextView alloc] init];
        _inputField.backgroundColor = [UIColor whiteColor];
        _inputField.textColor = [UIColor blackColor];
        _inputField.height = 36;
        _inputField.width  = SCREEN_WIDTH - 3 * ELChatBarButtonWidth - 2 * 10;
        _inputField.left = ELChatBarButtonWidth + 10;
        _inputField.top  = (ELChatBarHeight - _inputField.height)/2;
        _inputField.font = [UIFont systemFontOfSize:14.];
        _inputField.layer.masksToBounds = YES;
        _inputField.layer.cornerRadius = 4.0f;
        _inputField.layer.borderWidth = 0.5f;
        _inputField.layer.borderColor= self.barTopLine.backgroundColor.CGColor;
        _inputField.scrollsToTop = NO;
        _inputField.returnKeyType = UIReturnKeySend;
        _inputField.delegate = self;
        // 观察者监听高度变化
        [_inputField addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return _inputField;
}

- (UIButton *)audioLpButton
{
    if (!_audioLpButton) {
        _audioLpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _audioLpButton.frame = self.inputField.frame;
        [_audioLpButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_audioLpButton setTitle:@"松开 发送" forState:UIControlStateHighlighted];
        [_audioLpButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_audioLpButton setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateHighlighted];
        _audioLpButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _audioLpButton.layer. masksToBounds = YES;
        _audioLpButton.layer.cornerRadius = 4.0f;
        _audioLpButton.layer.borderWidth = 0.5f;
        [_audioLpButton.layer setBorderColor:self.barTopLine.backgroundColor.CGColor];
        // 按下录音按钮
        [_audioLpButton addTarget:self action:@selector(audioLpButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        // 手指离开录音按钮, 但不松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveOut:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragOutside];
        // 手指离开录音按钮 , 松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveOutTouchUp:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        // 手指回到录音按钮, 但不松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonMoveInside:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragEnter];
        // 手指回到录音按钮 , 松开
        [_audioLpButton addTarget:self action:@selector(audioLpButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioLpButton;
}

- (ELAudioRecordView *)audioRecordView
{
    if (!_audioRecordView) {
        _audioRecordView = [[ELAudioRecordView alloc] init];
    }
    return _audioRecordView;
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  按下录音按钮的回调
 */
- (void)clickAudioButtonAction
{
    self.audioButton.selected = !self.audioButton.isSelected;
    if (self.audioButton.isSelected) {
        self.status = ELChatBarStatusRecord;
    } else {
        self.status = ELChatBarStatusSystemKeyboard;
    }
    // 更新UI
    [self refreshUI:NO];
}

/**
 *  按下表情按钮的回调
 */
- (void)clickEmotionButtonAction
{
    self.emotionButton.selected = !self.emotionButton.isSelected;
    if (self.emotionButton.isSelected) {
        self.status = ELChatBarStatusEmotion;
    } else {
        self.status = ELChatBarStatusSystemKeyboard;
    }
    // 更新UI
    [self refreshUI:NO];
    // 回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarUp)]) {
        [self.delegate chatBarUp];
    }
}

/**
 *  按下更多按钮的回调
 */
- (void)clickMoreButtonAction
{
    self.moreButton.selected = !self.moreButton.isSelected;
    if (self.moreButton.isSelected) {
        self.status = ELChatBarStatusMore;
    } else {
        self.status = ELChatBarStatusSystemKeyboard;
    }
    // 更新UI
    [self refreshUI:NO];
    // 回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarUp)]) {
        [self.delegate chatBarUp];
    }
}

#pragma mark - 👀 录音事件 👀 💤

/// 语音按钮点击
- (void)audioLpButtonTouchDown:(UIButton *)audioLpButton
{
    // 开始录音
    [self.audioRecordView startRecord];
}

/// 手指离开录音按钮 , 但不松开
- (void)audioLpButtonMoveOut:(UIButton *)audioLpButton
{
    [self.audioRecordView moveOut];
}

/// 手指离开录音按钮 , 松开
- (void)audioLpButtonMoveOutTouchUp:(UIButton *)audioLpButton
{
    [self.audioRecordView cancelRecord];
}

/// 手指回到录音按钮,但不松开
- (void)audioLpButtonMoveInside:(UIButton *)audioLpButton
{
    [self.audioRecordView continueRecord];
}

/// 手指回到录音按钮 , 松开
- (void)audioLpButtonTouchUpInside:(UIButton *)audioLpButton
{
    @weakify(self);
    [self.audioRecordView stopRecord:^(NSString *path, NSInteger seconds) {
        @strongify(self);
        // 回调代理
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:audioRecordDidFinish:duration:)]) {
            [self.delegate chatBar:self audioRecordDidFinish:path duration:seconds];
        }
    }];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  根据传递过来的参数快速生成一个按钮
 *
 *  @param x X坐标
 *  @param normalImageName 普通状态下的图片
 *  @param selectedImageName 选中状态下的图片
 */
- (UIButton *)chatBarButtonWithX:(CGFloat)x
                 normalImageName:(NSString *)normalImageName
               selectedImageName:(NSString *)selectedImageName
                     clickAction:(SEL)clickAction
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(x, (ELChatBarHeight-ELChatBarButtonHeight)/2, ELChatBarButtonWidth, ELChatBarButtonHeight);
    [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    [button addTarget:self action:clickAction forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/**
 *  删除按键被触发（包括系统键盘和表情键盘上的删除）
 */
- (BOOL)delete
{
    NSMutableString *text = [[NSMutableString alloc] initWithString:self.inputField.text];
     // 当前光标位置
     NSInteger location = self.inputField.selectedRange.location;
     if (!text.length) return YES;
     
     // 正则检测是否存在表情
     NSRegularExpression *pression = [NSRegularExpression regularExpressionWithPattern:ELEmotionRegex options:NSRegularExpressionCaseInsensitive error:NULL];
     NSArray *results = [pression matchesInString:self.inputField.text options:NSMatchingReportProgress range:NSMakeRange(0, self.inputField.text.length)];
     // 检测光标前是否是表情
     __block BOOL deleteEmotion = NO;
     [results enumerateObjectsUsingBlock:^(NSTextCheckingResult  *_Nonnull checkResult, NSUInteger idx, BOOL * _Nonnull stop) {
         // 光标前面有表情
         if (checkResult.range.location + checkResult.range.length == location) {
             [text replaceCharactersInRange:checkResult.range withString:@""];
             self.inputField.text = text;
             // 光标前移
             self.inputField.selectedRange = NSMakeRange(location - checkResult.range.length, 0);
             deleteEmotion = YES;
             *stop = YES;
         }
     }];
    
    return !deleteEmotion;
     
     // 光标前没有表情
//     if (!deleteEmotion) {
//         [self.inputField deleteBackward];
////         [text replaceCharactersInRange:NSMakeRange(text.length-1, 1) withString:@""];
////         self.inputField.text = text;
////         // 光标前移
////         self.inputField.selectedRange = NSMakeRange(location - 1, 0);
//     }
}

/**
 *  发送按键被触发包括系统键盘和表情键盘上的发送）
 */
- (void)send
{
    if (self.inputField.text.length <= 0)    return;
    
    // 回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didSend:)]) {
        [self.delegate chatBar:self didSend:self.inputField.text];
    }
    self.inputField.text = @"";
    // 更新输入框高度
    [self updateInputFieldHeight:ELChatBarInputDefaultHeight];
}

/**
 *  更新键盘输入框的高度
 */
- (void)updateInputFieldHeight:(CGFloat)height
{
    self.barContainer.height = height + self.inputField.top * 2;
    self.inputField.top = (self.barContainer.height - height) * 0.5;
    self.inputField.height = height;
    self.keyboardContainer.top = self.barContainer.bottom;
    // 更新整个控件的尺寸
    self.height = _keyboardHeight + self.barContainer.height + _safeAreaBottom;
    self.top = SCREEN_HEIGHT - self.height - STATUS_AND_NAVIGATION_BAR_HEIGHT;
}

/**
 *  更新 UI
 */
- (void)refreshUI:(BOOL)isInitialize
{
    // 当前键盘的高度
    CGFloat currentKeyboardH = 0;
    // 当前 bar 的高度
    CGFloat barHeight = self.barContainer.height;
    
    if (IS_IPHONE_X_) {
        _safeAreaBottom = 34.;
    }
    
    self.keyboardContainer.hidden = YES;
    
    switch (self.status) {
        case ELChatBarStatusDefault: {
            /// 默认状态，键盘未升起，且不是录音状态
            self.audioButton.selected = NO;
            self.audioLpButton.hidden = YES;
            self.inputField.hidden = NO;
            self.emotionButton.selected = NO;
            self.moreButton.selected = NO;
            [self.inputField resignFirstResponder];
            currentKeyboardH = 0;
            break;
        }
        case ELChatBarStatusSystemKeyboard: {
            /// 系统键盘升起状态
            self.audioButton.selected = NO;
            self.audioLpButton.hidden = YES;
            self.inputField.hidden = NO;
            self.emotionButton.selected = NO;
            self.moreButton.selected = NO;
            [self.inputField becomeFirstResponder];
            currentKeyboardH = _keyboardHeight;
            _safeAreaBottom = 0;
            break;
        }
        case ELChatBarStatusEmotion: {
            /// 表情键盘
            self.audioButton.selected = NO;
            self.audioLpButton.hidden = YES;
            self.inputField.hidden = NO;
            self.emotionButton.selected = YES;
            self.moreButton.selected = NO;
            [self.inputField resignFirstResponder];
            // 显示表情键盘
            self.keyboardContainer.hidden = NO;
            self.moreView.hidden = YES;
            self.emotionView.hidden = NO;
            currentKeyboardH = _keyboardHeight;
            break;
        }
        case ELChatBarStatusMore: {
            /// 更多状态
            self.audioButton.selected = NO;
            self.audioLpButton.hidden = YES;
            self.inputField.hidden = NO;
            self.emotionButton.selected = NO;
            self.moreButton.selected = YES;
            [self.inputField resignFirstResponder];
            currentKeyboardH = _keyboardHeight;
            // 显示“更多”
            self.keyboardContainer.hidden = NO;
            self.moreView.hidden = NO;
            self.emotionView.hidden = YES;
            break;
        }
        case ELChatBarStatusRecord: {
            /// 录音状态
            self.audioButton.selected = YES;
            self.audioLpButton.hidden = NO;
            self.inputField.hidden = YES;
            self.emotionButton.selected = NO;
            self.moreButton.selected = NO;
            [self.inputField resignFirstResponder];
            currentKeyboardH = 0;
            barHeight = ELChatBarHeight;
            break;
        }
    }
    
    /// 更新整个控件的 frame
    CGFloat h = currentKeyboardH + barHeight + _safeAreaBottom;
    CGFloat y = SCREEN_HEIGHT - h - STATUS_AND_NAVIGATION_BAR_HEIGHT;
    if (isInitialize) { // 第一次初始化
        self.height = h;
        self.width = SCREEN_WIDTH;
        self.top = y;
    } else {    // 更新
        [UIView animateWithDuration:(_duration<0.01 ? 0.25 : _duration) animations:^{
            self.top = y;
            self.height = h;
        }];
    }
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)hideKeyboard
{
    self.status = ELChatBarStatusDefault;
    // 隐藏键盘
    [self keyboardWillHide];
}

#pragma mark - 👀 UITextViewDelegate 👀 💤

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""]) { // 删除键监听
        // 系统键盘删除
        return [self delete];
    } else if ([text isEqualToString:@"\n"]) { // 发送键监听
        // 发送普通文本消息
        [self send];
        return NO;
    }
    return YES;
}

@end
