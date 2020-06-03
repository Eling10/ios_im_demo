//
//  ELTarBarController.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/28.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELTarBarController.h"
#import "ElingIM.h"
#import "ELColorMacros.h"
#import "ELUtilMacros.h"
#import "ELNotificationHelper.h"
#import "ELNavigationController.h"
#import <XCMacros/XCMacros.h>

#import "ELRootViewControllerHelper.h"

@interface ELTarBarController ()<ELNotificationsDelegate, ELLoginManagerDelegate, ELChatManagerDelegate, ELGroupManagerDelegate>

@end

@implementation ELTarBarController

+ (void)initialize
{
    /// 此处设置 tabBarItem 的一些常用属性
    // 设置 选中的文字颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ELYTABBAR_NOR_TITLE_COLOR} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ELYTABBAR_SEL_TITLE_COLOR} forState:UIControlStateSelected];
    
    // 设置间距
    [UITabBar appearance].translucent = NO;
}

- (void)dealloc
{
    [[ELNotificationHelper sharedInstance] removeDelegate:self];
    [[ELClient sharedClient].chatManager removeDelegate:self];
    [[ELClient sharedClient].loginManager removeDelegate:self];
    [[ELClient sharedClient].groupManager removeDelegate:self];
    [NOTIFICATION_CENTER removeObserver:self];
}

#pragma mark - ⏳ 👀 LifeCycle Method 👀

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 注册通知
    [self registerNotification];
    
    /// 设置 UI
    [self setupUI];
}

#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    /// 添加子控制器
    [self addChildViewController:@"ELConversationViewController"
                           title:@"聊天"
                         imgName:@"tabbar_chat_gray"
                      selImgName:@"tabbar_chat_blue"];
    [self addChildViewController:@"ELContactViewController"
                           title:@"联系人"
                         imgName:@"tabbar_contacts_gray"
                      selImgName:@"tabbar_contacts_blue"];
    [self addChildViewController:@"ELProfileViewController"
                           title:@"我"
                         imgName:@"tabbar_me_gray"
                      selImgName:@"tabbar_me_blue"];
    
    /// 红点数量
    [self _loadTabBarItemsBadge];
}

#pragma mark - 👀 注册通知 👀 💤

- (void)registerNotification
{
    [[ELNotificationHelper sharedInstance] addDelegate:self];
    [[ELClient sharedClient].chatManager addDelegate:self];
    [[ELClient sharedClient].groupManager addDelegate:self];
    [[ELClient sharedClient].loginManager addDelegate:self];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(_loadConversationTabBarItemBadge) name:ELCONVERSATION_UNREAD_COUNT_TO_ZERO object:nil];
    [NOTIFICATION_CENTER addObserver:self selector:@selector(_loadConversationTabBarItemBadge) name:EL_CONTACT_DELETE_SUCCESS object:nil];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  添加子控制器
 *
 *  @param viewControllerClassName 控制器类名
 *  @param title        标题
 *  @param imgName      普通状态下的图片名称
 *  @param selImgName   选中状态下的图片名称
 */
- (void)addChildViewController:(NSString *)viewControllerClassName
                         title:(NSString *)title
                       imgName:(NSString *)imgName
                    selImgName:(NSString *)selImgName
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title
                                                       image:[[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               selectedImage:[[UIImage imageNamed:selImgName]
                                                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UIViewController *vc = [[NSClassFromString(viewControllerClassName) alloc] init];
    ELNavigationController *navVc = [[ELNavigationController alloc] initWithRootViewController:vc];
    navVc.tabBarItem = item;
    [self addChildViewController:navVc];
}

/**
 *  加载未读数量
 */
- (void)_loadTabBarItemsBadge
{
    /// 通知未读数
    [self _loadNotificationTabBarItemBadge:[ELNotificationHelper sharedInstance].unreadCount];
    /// 消息未读数
    [self _loadConversationTabBarItemBadge];
}

/// 加载消息未读数量
- (void)_loadConversationTabBarItemBadge
{
    @weakify(self);
    [[ELClient sharedClient].chatManager getAllConversations:^(NSArray<ELConversation *> *conversations, NSError *aError) {
        @strongify(self);
        NSInteger unreadCount = 0;
        for (ELConversation *conversation in conversations) {
            unreadCount += conversation.unreadMessagesCount;
        }
        
        UIViewController *vc = self.viewControllers.firstObject;
        if (unreadCount > 0) {
            vc.tabBarItem.badgeValue = @(unreadCount).stringValue;
        } else {
            vc.tabBarItem.badgeValue = nil;
        }
    }];
}

/// 加载通知未读数量
- (void)_loadNotificationTabBarItemBadge:(NSInteger)aUnreadCount
{
    UIViewController *vc = self.viewControllers[1];
    if (aUnreadCount > 0) {
        vc.tabBarItem.badgeValue = @(aUnreadCount).stringValue;
    } else {
        vc.tabBarItem.badgeValue = nil;
    }
}

#pragma mark - 💉 👀 ELNotificationsDelegate 👀

- (void)didNotificationsUnreadCountUpdate:(NSInteger)aUnreadCount
{
    /// 加载通知未读数量
    [self _loadNotificationTabBarItemBadge:aUnreadCount];
}

#pragma mark - 👀 ELChatManagerDelegate 👀 💤

- (void)messageDidReceive:(ELMessage *)aMessages
{
    /// 加载消息未读数量
    [self _loadConversationTabBarItemBadge];
}

- (void)conversationListDidUpdate
{
    /// 加载消息未读数量
    [self _loadConversationTabBarItemBadge];
}

#pragma mark - 💉 👀 ELGroupManagerDelegate 👀

/**
 *  当群被解散的通知（群主不会收到此回调）
 *
 *  @param groupId 群ID
 */
- (void)groupDidDissolution:(NSString *)groupId
{
    /// 加载消息未读数量
    [self _loadConversationTabBarItemBadge];
}

/**
 *  自己被移出群组的通知（自己主动退群的不会收到此回调）
 *
 *  @param aGroupId 群组ID
 */
- (void)userDidDeleteFromGroup:(NSString *)aGroupId
{
    /// 加载消息未读数量
    [self _loadConversationTabBarItemBadge];
}

#pragma mark - 💉 👀 ELLoginManagerDelegate 👀

- (void)loginStatusDidInvalid
{
    DLog(@"登录失效了，请重新登录");
    [ELRootViewControllerHelper chooseRootViewControllerWithType:ELRootViewControllerTypeLogin];
}

@end
 
