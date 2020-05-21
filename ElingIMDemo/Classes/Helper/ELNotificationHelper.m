//
//  ELNotificationHelper.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：通知管理类 🐾
 */


#import "ELNotificationHelper.h"
#import "ElingIM.h"
#import <XCDateUnit/XCDateUnit.h>
#import <XCMacros/XCMacros.h>

static ELNotificationHelper *_instance = nil;

@interface ELNotificationHelper ()<ELContactManagerDelegate>

@property (nonatomic, strong) EMMulticastDelegate<ELNotificationsDelegate> *delegates;
/// 文件名
@property (nonatomic, strong, readonly) NSString *fileName;

@end

@implementation ELNotificationHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ELNotificationHelper alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = (EMMulticastDelegate<ELNotificationsDelegate> *)[[EMMulticastDelegate alloc] init];
        /// 添加联系人代理
        [[ELClient sharedClient].contactManager addDelegate:self];
        [self initializeUserNotifications];
    }
    
    return self;
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  加载本地通知数据
 */
- (void)_getNotificationsFromLocal
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.fileName];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    [self.notificationList removeAllObjects];
    [self.notificationList addObjectsFromArray:array];
    
    _unreadCount = [self _getUnreadCount];
    [self.delegates didNotificationsUnreadCountUpdate:_unreadCount];
}

/**
 *  获取未读数
 */
- (NSInteger)_getUnreadCount
{
    NSInteger ret = 0;
    for (ELNotificationModel *model in self.notificationList) {
        if (!model.isRead) {
            ++ret;
        }
    }
    return ret;
}

#pragma mark - 🔓 👀 Public Method 👀

- (void)initializeUserNotifications
{
    _notificationList = [NSMutableArray array];
    _fileName = [NSString stringWithFormat:@"eling_notifications_%@.data", [ELClient sharedClient].userManager.currentUser.userId];
    /// 加载本地数据
    [self _getNotificationsFromLocal];
}

- (void)addDelegate:(id<ELNotificationsDelegate>)aDelegate
{
    [self.delegates addDelegate:aDelegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<ELNotificationsDelegate>)aDelegate
{
    [self.delegates removeDelegate:aDelegate];
}

- (void)markAllAsRead
{
    BOOL isArchive = NO;
    for (ELNotificationModel *model in self.notificationList) {
        if (!model.isRead) {
            model.isRead = YES;
            isArchive = YES;
        }
    }
    
    if (isArchive) {
        [self save];
    }
    
    if (self.unreadCount != 0) {
        _unreadCount = 0;
        [self.delegates didNotificationsUnreadCountUpdate:_unreadCount];
    }
}

- (void)save
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:self.fileName];
    [NSKeyedArchiver archiveRootObject:self.notificationList toFile:file];
}

#pragma mark - 💉 👀 ELContactManagerDelegate 👀

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage
{
    if ([aUsername length] == 0) {
        return;
    }
    
    /// 获取用户信息
    @weakify(self);
    [[ELClient sharedClient].userManager getUserInformation:aUsername completion:^(NSError *error, ELUserInformation *information) {
        @strongify(self);
        /// 生成数据模型
        ELNotificationModel *aModel = [[ELNotificationModel alloc] init];
        aModel.sender = aUsername;
        aModel.message = aMessage;
        aModel.time = @((NSInteger)([[NSDate date] timeIntervalSince1970] * 1000)).description;
        if (!error) {
            aModel.senderAvatar = information.avatarUrl;
            aModel.senderName = information.nickName ?: information.userName;
        }
        
        for (ELNotificationModel *model in self.notificationList) {
            if ([model.sender isEqualToString:aModel.sender]) {
                [self.notificationList removeObject:model];
                break;
            }
        }
        
        ++ self->_unreadCount;
        [self.delegates didNotificationsUnreadCountUpdate:self.unreadCount];
        [self.notificationList insertObject:aModel atIndex:0];
        [self save];
        [self.delegates didNotificationsUpdate];
    }];
}


@end
