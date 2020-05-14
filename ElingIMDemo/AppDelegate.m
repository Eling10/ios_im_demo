

#import "AppDelegate.h"
#import "ElingIMDemoHeader.h"
#import "ELCallHelper.h"
#import "ELNotificationHelper.h"
#import "ELRootViewControllerHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /// 初始化聊天 SDK
    ELClientOptions *o = [ELClientOptions new];
    o.appId = AppID;
    o.appSecret = AppScret;
    
    ELIMOptions *imO = [ELClient sharedClient].imOptions;
    imO.serverURL = SERVICE_URL;
    imO.imURL = IM_URL;
    imO.chatRoomURL = CHAT_ROOM_URL;
    imO.voipURL = VOIP_URL;
    
    [[ELClient sharedClient] initializeSDKWithOptions:o];
    
    // 初始化
    [ELCallHelper sharedHelper];
    [ELNotificationHelper sharedInstance];
    [ELRootViewControllerHelper chooseRootViewController];
       
    return YES;
}

@end
