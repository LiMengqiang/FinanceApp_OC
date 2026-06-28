#import "AppDelegate.h"
#import "FOTabBarController.h"

@implementation AppDelegate

// 调用方：UIApplicationMain；作用：应用启动后创建主窗口并挂载 Tab 根控制器。
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[FOTabBarController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
