//
//  ELChatViewController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELChatViewController.h"

#import "ELGroupDetailViewController.h"

#import "ELChatBar.h"
#import "ELCallHelper.h"
#import "ELCoreTextView.h"
#import "ELMessageCell.h"
#import "ELMessageTimeCell.h"

#import "ElingIM.h"
#import "ELUtilMacros.h"
#import "ELDateHelper.h"
#import "ELConversationHelper.h"
#import "ELAudioPlayerHelper.h"
#import "UIScrollView+Refresh.h"
#import "UIView+ELExtension.h"

#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <Masonry/Masonry.h>
#import <XCMacros/XCMacros.h>
#import <XCCategory/UIView+XCExtension.h>
#import <XCCategory/UIColor+XCExtension.h>
#import <XCCustomItemView/XCCustomItemView.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <XCPhotoBrowser/XCPhotoBrowserManager.h>

@interface ELChatViewController ()<ELChatBarDelegate, ELChatManagerDelegate, ELMessageCellDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) ELConversation *conversation;
/// 目标对象的名称
@property (copy, nonatomic) NSString *toName;
/// 目标对象的头像
@property (copy, nonatomic) NSString *toAvatar;
/// 会话类型
@property (assign, nonatomic) ELChatType chatType;

/// 聊天输入框
@property (weak, nonatomic) ELChatBar *chatBar;
@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

/// 消息格式化
@property (assign, nonatomic) NSTimeInterval messageTimeTag;

@end

static NSString *const ELMessageTimeCellIdentifier = @"ELMessageTimeCellIdentifier";

@implementation ELChatViewController

- (instancetype)initWithConversation:(ELConversation *)conversation
{
    self = [super init];
    if (self) {
        _conversation = conversation;
        _toName = [ELConversationHelper nameFromConversation:conversation];
        _toAvatar = [ELConversationHelper avatarFromConversation:conversation];
        _chatType = conversation.latestMessage.chatType;
    }
    return self;
}

- (instancetype)initWithConversationId:(NSString *)conversationId
                                  type:(ELChatType)type
                                toName:(NSString *)toName
                              toAvatar:(NSString *)toAvatar
{
    self = [super init];
    if (self) {
        _conversation = [ELConversation new];
        _conversation.conversationId = conversationId;
        _toName = toName;
        _toAvatar = toAvatar;
        _chatType = type;
    }
    return self;
}

- (void)dealloc
{
    [NOTIFICATION_CENTER removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageTimeTag = -1;
    
    /// 设置 UI
    [self setupUI];
    
    /// 设置 IM
    [self setupIM];
    
    /// 加载数据
    [self loadData:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.chatBar hideKeyboard];

    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

#pragma mark - 🔑 👀 Getter Method 👀

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

#pragma mark - 👀 设置UI 👀 💤

- (void)setupUI
{
    /// 标题
    self.title = self.toName;
    if (self.chatType == ELChatTypeChat) {  // 单聊
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_clear"] style:UIBarButtonItemStyleDone target:self action:@selector(tapClearMessageAction)];
    } else {    // 群聊
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_info"] style:UIBarButtonItemStyleDone target:self action:@selector(tapGroupInfoAction)];
    }
    
    /// 键盘输入框
    ELChatBar *chatBar = [[ELChatBar alloc] init];
    self.chatBar = chatBar;
    self.chatBar.delegate = self;
    @weakify(self);
    XCCustomItemModel *photoM = [[XCCustomItemModel alloc] initWithImage:[UIImage imageNamed:@"more_pic"] title:@"照片" didClickHandle:^{
        @strongify(self);
        [self chatBarDidPhotoAction];
    }];
    XCCustomItemModel *cameraM = [[XCCustomItemModel alloc] initWithImage:[UIImage imageNamed:@"more_camera"] title:@"拍摄" didClickHandle:^{
        @strongify(self);
        [self chatBarDidCameraAction];
    }];
    XCCustomItemModel *callM = [[XCCustomItemModel alloc] initWithImage:[UIImage imageNamed:@"more_video"] title:@"视频通话" didClickHandle:^{
        @strongify(self);
        [self chatBarDidCallAction];
    }];
    NSArray *itemMs = self.chatType == ELChatTypeChat ? @[photoM, cameraM, callM] : @[photoM, cameraM];
    CGRect f = CGRectMake(0, 0, chatBar.moreView.width, chatBar.moreView.height * 2 / 3);
    XCCustomItemView *moreView = [[XCCustomItemView alloc] initWithFrame:f itemModels:itemMs];
    [moreView updateItem:^(XCCustomItemConfigure *config) {
        config.column = 4;
        config.imageCornerRadius = 0;
        config.contentMode = UIViewContentModeScaleAspectFit;
        config.titleColor = [UIColor colorWithHexString:@"999999"];
    }];
    
    chatBar.delegate = self;
    [chatBar.moreView addSubview:moreView];
    [self.view addSubview:self.chatBar];

    /// tableView
    UITableView *tableview = [[UITableView alloc] init];
    self.tableView = tableview;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 130;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.chatBar.mas_top);
    }];
    self.tableView.loadNewDataHandle = ^{
        @strongify(self);
        self.page ++;
        [self loadData:NO];
    };
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTableViewAction:)];
    [self.tableView addGestureRecognizer:tap];
}

#pragma mark - 👀 设置 IM 👀 💤

- (void)setupIM
{
    /// 添加聊天代理
    [[ELClient sharedClient].chatManager addDelegate:self];
    
    /// 通话结束的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(receiveCallEndNotification:) name:ELCALL_END object:nil];
    /// 群组信息修改成功的通知
    [NOTIFICATION_CENTER addObserver:self selector:@selector(updateGroupNotification:) name:EL_GROUP_UPDATE_SUCCESS object:nil];
    /// 群被解散、或者被移出当前群聊
    [NOTIFICATION_CENTER addObserver:self selector:@selector(backToPre) name:EL_GROUP_EXIT_SUCCESS object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(backToPre) name:EL_GROUP_DISSOLUTION_SUCCESS object:nil];

    /// 将此消息的所有会话标记为已读
    [[ELClient sharedClient].chatManager markAllMessagesAsRead:self.conversation.conversationId completion:^(NSError *aError) {
        if (!aError) {
            // 更新内存中的消息状态
            self.conversation.unreadMessagesCount = 0;
            self.conversation.latestMessage.isRead = YES;
            // 标记已读的通知
            [NOTIFICATION_CENTER postNotificationName:ELCONVERSATION_UNREAD_COUNT_TO_ZERO object:nil];
        }
    }];
}

#pragma mark - 👀 通知 👀 💤

/// 收到通话结束的通知
- (void)receiveCallEndNotification:(NSNotification *)noti
{
    // 刷新列表
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *formated = [self _formatMessages:@[noti.object]];
        [self.dataSource addObjectsFromArray:formated];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self _scrollToBottomRow];
        });
    });
}

/**
 *  群组信息发生改变的通知
 */
- (void)updateGroupNotification:(NSNotification *)noti
{
    if (self.chatType != ELChatTypeGroupChat)   return;
    ELGroup *group = noti.object;
    self.toName = group.groupName;
    self.toAvatar = group.groupAvatar;
    // 更新标题
    self.title = self.toName;
}

/**
 *  返回上一级页面
 */
- (void)backToPre
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 👀 加载数据 👀 💤

- (void)loadData:(BOOL)scrollToBottom
{
    @weakify(self);
    void (^block)(NSArray<ELMessage *> *aMessages, NSError *aError) = ^(NSArray *aMessages, NSError *aError) {
        @strongify(self);
        if (!aError && [aMessages count]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSArray *formated = [self _formatMessages:aMessages];
                [self.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    if (scrollToBottom) {
                        [self _scrollToBottomRow];
                    }
                });
            });
        }
        [self.tableView endRefreshing];
    };
    
    /// 加载数据（本地数据）
    [[ELClient sharedClient].chatManager getMessages:self.conversation.conversationId page:self.page size:self.pageSize completion:^(NSArray<ELMessage *> *messages, NSError *aError) {
        block(messages, aError);
    }];
}

#pragma mark - Gesture Recognizer

- (void)handleTapTableViewAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {
        [self.chatBar hideKeyboard];
    }
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  点击清空消息的回调
 */
- (void)tapClearMessageAction
{
    @weakify(self);
    [[ELClient sharedClient].chatManager removeMessages:self.conversation.conversationId completion:^(NSError *aError) {
        @strongify(self);
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
    }];
}

/**
 *  点击群组详情的回调
 */
- (void)tapGroupInfoAction
{
    // 跳转到群组详情页面
    ELGroupDetailViewController *vc = [[ELGroupDetailViewController alloc] initWithGroupId:self.conversation.conversationId];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  图片消息被点击
 */
- (void)_imageMessageCellDidSelected:(ELMessageCell *)cell
{
    ELImageMessageBody *body = (ELImageMessageBody *)cell.model.body;
    UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
    if (image) {
        [XCPhotoBrowserManager showFromViewController:self.navigationController selectedIndex:0 seletedImageView:cell.bubbleView images:@[image] configure:nil];
    } else {
        NSArray *thumbImgs = cell.bubbleView.image ? @[cell.bubbleView.image] : nil;
        [XCPhotoBrowserManager showFromViewController:self.navigationController selectedIndex:0 seletedImageView:cell.bubbleView urls:@[body.remotePath ?: @""] thumbImgs:thumbImgs configure:nil];
    }
}

/**
 *  语音消息被点击
 */
- (void)_audioMessageCellDidSelected:(ELMessageCell *)cell
{
    ELMessage *message = cell.model;
    ELVoiceMessageBody *body = (ELVoiceMessageBody *)cell.model.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (body.isPlaying) {
        [[ELAudioPlayerHelper sharedHelper] stopPlayer];
        body.isPlaying = NO;
        [self.tableView reloadData];
        return;
    }
        
    if (body.downloadStatus == ELFileDownloadStatusDownloading) {
        [self.view showText:@"正在下载语音，请稍后点击"];
        return;
    }
    
    @weakify(self);
    void (^playBlock)(ELVoiceMessageBody *aModel) = ^(ELVoiceMessageBody *aModel) {
        @strongify(self);
        id model = [ELAudioPlayerHelper sharedHelper].model;
        if (model && [model isKindOfClass:[ELVoiceMessageBody class]]) {
            ELVoiceMessageBody *oldModel = (ELVoiceMessageBody *)model;
            if (oldModel.isPlaying) {
                oldModel.isPlaying = NO;
            }
        }
        aModel.isPlaying = YES;
        [self.tableView reloadData];
         
        [[ELAudioPlayerHelper sharedHelper] startPlayerWithPath:body.localPath model:aModel completion:^(NSError *error) {
            aModel.isPlaying = NO;
            [self.tableView reloadData];
        }];
    };
        
    if (body.downloadStatus == ELFileDownloadStatusSucceed  && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body);
        return;
    }
    [self.view showHUDWithText:@"下载语音..."];
    [[ELClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(NSError *error) {
        @strongify(self);
        [self.view hideHUD];
        if (error) {
            [self.view showText:@"下载语音失败" completion:nil];
        } else {
            playBlock(body);
        }
    }];
}


- (void)_videoMessageCellDidSelected:(ELMessageCell *)aCell
{
    ELVideoMessageBody *body = (ELVideoMessageBody*)aCell.model.body;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (body.downloadStatus == ELFileDownloadStatusDownloading) {
        [self.view showText:@"正在下载视频,稍后点击"];
        return;
    }
    
    @weakify(self);
    void (^playBlock)(NSString *aPath) = ^(NSString *aPath) {
        @strongify(self);
        NSURL *videoURL = [NSURL fileURLWithPath:aPath];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        [self presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
    };
    
    if (body.downloadStatus == ELFileDownloadStatusSucceed && [fileManager fileExistsAtPath:body.localPath]) {
        playBlock(body.localPath);
        return;
    }
    
    [self.view showHUDWithText:@"下载视频..."];
    [[ELClient sharedClient].chatManager downloadMessageAttachment:aCell.model progress:nil completion:^(NSError *error) {
        @strongify(self);
        [self.view hideHUD];
        if (error) {
            [self.view showText:@"下载视频失败" completion:nil];
        } else {
            playBlock([body localPath]);
        }
    }];
}

/**
 *  点击 chatBar 上选择图片
 */
- (void)chatBarDidPhotoAction
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: { // 已获取权限
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                    break;
                }
                case PHAuthorizationStatusDenied: // 用户已经明确否认了这一照片数据的应用程序访问
                    [self.view showText:@"不允许访问相册"];
                    break;
                case PHAuthorizationStatusRestricted: // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
                    [self.view showText:@"没有授权访问相册"];
                    break;
                default:
                    [self.view showText:@"访问相册失败"];
                    break;
            }
        });
    }];
}

/**
 *  点击 chatBar 上相机
 */
- (void)chatBarDidCameraAction
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

/**
 *  点击 chatBar 上音视频通话
 */
- (void)chatBarDidCallAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"实时通话类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    @weakify(self);
    [alertController addAction:[UIAlertAction actionWithTitle:@"语音通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [[ELCallHelper sharedHelper] callTo:self.conversation.conversationId callType:ELCallTypeAudio];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"视频通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [[ELCallHelper sharedHelper] callTo:self.conversation.conversationId callType:ELCallTypeVideo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  处理消息，将消息的时间添加到数组中，作为一种消息
 */
- (NSArray *)_formatMessages:(NSArray<ELMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    for (NSInteger i = aMessages.count-1; i >= 0; i--) {
        ELMessage *msg = aMessages[i];
        CGFloat interval = (self.messageTimeTag - msg.sendTime) / 1000;
        if (self.messageTimeTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [ELDateHelper formattedTimeFromTimeInterval:msg.sendTime];
            [formated addObject:timeStr];
            self.messageTimeTag = msg.sendTime;
        }
        [formated addObject:msg];
    }
    return formated;
}

/**
 *  滚动到最底部
 */
- (void)_scrollToBottomRow
{
    if ([self.dataSource count] > 0) {
        NSInteger toRow = self.dataSource.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (NSURL *)_videoConvert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [[ELClient sharedClient].chatManager getMessageAttachmentCachePath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    DLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    DLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    DLog(@"completed.");
                } break;
                default: {
                    DLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            DLog(@"timeout.");
        }
        
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}


#pragma mark - 👀 消息发送 👀 💤

/**
 *  发送文本消息
 */
- (void)_sendTextMessage:(NSString *)aText
                     ext:(NSDictionary *)aExt
{
    if ([aText length] == 0) {
        return;
    }
    // 文本消息体
    ELTextMessageBody *body = [ELTextMessageBody new];
    body.text = aText;
    [self _sendMessageWithBody:body ext:aExt];
}

/**
 *  发送语音消息
 *
 *  @param localPath 本地路径
 *  @param seconds 录音时长（秒）
 */
- (void)_sendAudioMessage:(NSString *)localPath duration:(int)seconds
{
    ELVoiceMessageBody *body = [[ELVoiceMessageBody alloc] initWithLocalPath:localPath displayName:@"audio"];
    body.duration = seconds;
    [self _sendMessageWithBody:body ext:nil];
}

/**
 *  发送视频消息
 *
 *  @param localPath 视频时间
 */
- (void)_sendVideoMessage:(NSString *)localPath
{
    ELVideoMessageBody *body = [[ELVideoMessageBody alloc] initWithLocalPath:localPath displayName:@"video.mp4"];
    [self _sendMessageWithBody:body ext:nil];
}

/**
 *  发送图片消息
 *
 *  @param imageData 图片数据
 */
- (void)_sendImageMessage:(NSData *)imageData
{
    ELImageMessageBody *body = [[ELImageMessageBody alloc] initWithData:imageData displayName:@"image"];
    [self _sendMessageWithBody:body ext:nil];
}

/**
 *  发送消息
 *
 *  @param aBody 消息体
 *  @param aExt 消息拓展字段
 */
- (void)_sendMessageWithBody:(ELMessageBody *)aBody
                         ext:(NSDictionary *)aExt
{
    ELMessage *message = [[ELMessage alloc] initWithConversationId:self.conversation.conversationId toName:self.toName toAvatar:self.toAvatar body:aBody ext:aExt];
    message.chatType = self.chatType;
    
    if (self.chatType != ELChatTypeChat) {
        [self _sendMessage:message];
        return;
    }
    
    // 查询是否是好友关系，如果不是好友，则无法发送消息
    @weakify(self);
    [[ELClient sharedClient].chatManager getConversationFriendStatus:self.conversation.conversationId completion:^(BOOL isFriend, NSError *aError) {
        @strongify(self);
        if (isFriend) {
            [self _sendMessage:message];
        } else {
            [self.view showText:@"您和他还不是好友，无法发送消息"];
        }
    }];
}

/**
 *  发送消息
 *
 *  @param message 消息
 */
- (void)_sendMessage:(ELMessage *)message
{

    [[ELClient sharedClient].chatManager sendMessage:message completion:^(NSError *aError) {
        if (!aError) {
            DLog(@"发送成功");
            // 消息发送成功的通知
            [NOTIFICATION_CENTER postNotificationName:ELMESSAGE_SEND_SUCCESS object:nil];
        } else {
            DLog(@"发送失败：%@", aError.localizedDescription);
        }
    }];
    
    // 刷新列表
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *formated = [self _formatMessages:@[message]];
        [self.dataSource addObjectsFromArray:formated];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self _scrollToBottomRow];
        });
    });
}

#pragma mark - 📕 👀 UITableViewDataSource 👀

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.dataSource objectAtIndex:indexPath.row];
    
    // 时间的 cell
    if ([obj isKindOfClass:[NSString class]]) {
        ELMessageTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:ELMessageTimeCellIdentifier];
        if (!cell) {
            cell = [[ELMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ELMessageTimeCellIdentifier];
        }
        cell.timeLabel.text = obj;
        return cell;
    }
    
    // 消息的 cell
    ELMessage *message = obj;
    NSString *identifier = [ELMessageCell cellIdentifierWithDirection:message.direction type:message.body.type];
    ELMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ELMessageCell alloc] initWithDirection:message.direction type:message.body.type];
        cell.delegate = self;
    }
    cell.model = message;
    return cell;
}

#pragma mark - 👀 ELMessageCellDelegate 👀 💤

/**
 *  选中某个消息的回调
 */
- (void)messageCellDidSelect:(ELMessageCell *)aCell
{
    switch (aCell.model.body.type) {
        case ELMessageBodyTypeImage:
            [self _imageMessageCellDidSelected:aCell];
            break;
        case ELMessageBodyTypeVoice:
            [self _audioMessageCellDidSelected:aCell];
            break;
        case ELMessageBodyTypeVideo:
            [self _videoMessageCellDidSelected:aCell];
            break;
        default:
            break;
    }
}

#pragma mark - 👀 ELChatBarDelegate 👀 💤

- (void)chatBarUp
{
    /// 键盘升起时，滚动到最底部
    [self performSelector:@selector(_scrollToBottomRow) withObject:nil afterDelay:0.02];
}

/**
 *  录音完成
 */
- (void)chatBar:(ELChatBar *)bar audioRecordDidFinish:(NSString *)path duration:(NSInteger)seconds
{
    // 发送语音消息
    [self _sendAudioMessage:path duration:(int)seconds];
}

/**
 *  发送文字消息
 */
- (void)chatBar:(ELChatBar *)bar didSend:(NSString *)text
{
    /// 发送文本消息
    [self _sendTextMessage:text ext:nil];
}

#pragma mark - 💉 👀 ELChatManagerDelegate 👀

/**
 *  收到聊天消息
 */
- (void)messageDidReceive:(ELMessage *)aMessage
{
    /// 如果收到的消息不是该会话下的消息，则此页面不用处理
    if (![self.conversation.conversationId isEqualToString:aMessage.conversationId]) {
        return;
    }
    
    /// 将消息票房为已读，将同步到本地和服务器
    [[ELClient sharedClient].chatManager markMessageAsRead:aMessage.messageId completion:^(NSError *aError) {
        if (!aError) {
            // 标记已读的通知
            [NOTIFICATION_CENTER postNotificationName:ELCONVERSATION_UNREAD_COUNT_TO_ZERO object:nil];
        }
    }];
    
    /// 将消息添加到数组中
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *formated = [self _formatMessages:@[aMessage]];
        [self.dataSource addObjectsFromArray:formated];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self _scrollToBottomRow];
        });
    });
}

/**
 *  消息状态发生改变（消息附件的下载状态）
 */
- (void)messageStatusDidChange:(ELMessage *)aMessage error:(NSError *)aError
{
    /// 如果收到的消息不是该会话下的消息，则此页面不用处理
    if (![self.conversation.conversationId isEqualToString:aMessage.conversationId]) {
        return;
    }
    
    __block BOOL isReladView = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 找到对应的消息模型进行更新
        [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[ELMessage class]]) {
                ELMessage *model = (ELMessage *)obj;
                if ([model.messageId isEqualToString:aMessage.messageId]) {
                    isReladView = YES;
                    *stop = YES;
                }
            }
        }];
        if (isReladView) {  // 刷新列表
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    });
}

#pragma mark - 💉 👀 ELGroupManagerDelegate 👀

/**
 *  当群被解散的通知（群主不会收到此回调）
 *
 *  @param groupId 群ID
 */
- (void)groupDidDissolution:(NSString *)groupId
{
    // 返回上一级页面
    [self backToPre];
}

/**
 *  自己被移出群组的通知（自己主动退群的不会收到此回调）
 *
 *  @param aGroupId 群组ID
 */
- (void)userDidDeleteFromGroup:(NSString *)aGroupId
{
    // 返回上一级页面
    [self backToPre];
}


#pragma mark - 💉 👀 UIImagePickerControllerDelegate 👀

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // we will convert it to mp4 format
        NSURL *mp4 = [self _videoConvert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                DLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self _sendVideoMessage:mp4.path];
    } else {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            [self _sendImageMessage:data];
        } else {
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
            [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                if (asset) {
                    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                        if (data != nil) {
                            [self _sendImageMessage:data];
                        } else {
                            [self.view showText:@"图片太大，请选择其他图片"];
                        }
                    }];
                }
            }];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
