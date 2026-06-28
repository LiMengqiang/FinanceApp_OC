#import "FOTabBarController.h"
#import "FOMarketViewController.h"
#import "FOWatchlistViewController.h"
#import "FOProfileViewController.h"

@implementation FOTabBarController

// 调用方：UIKit 生命周期；作用：创建行情、自选、我的三个导航 Tab 并配置整体样式。
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = [self colorWithHex:0x0F766E];
    self.tabBar.barTintColor = [UIColor whiteColor];
    [self configureBarAppearances];
    
    FOMarketViewController *market = [[FOMarketViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *marketNav = [[UINavigationController alloc] initWithRootViewController:market];
    marketNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"行情" image:[self templateImageNamed:@"tab_market"] tag:0];
    [self styleNavigationController:marketNav];
    
    FOWatchlistViewController *watchlist = [[FOWatchlistViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *watchlistNav = [[UINavigationController alloc] initWithRootViewController:watchlist];
    watchlistNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"自选" image:[self templateImageNamed:@"tab_watchlist"] tag:1];
    [self styleNavigationController:watchlistNav];
    
    FOProfileViewController *profile = [[FOProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profile];
    profileNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[self templateImageNamed:@"tab_profile"] tag:2];
    [self styleNavigationController:profileNav];
    
    self.viewControllers = @[marketNav, watchlistNav, profileNav];
}

// 调用方：viewDidLoad；作用：按模板渲染模式读取 Tab 图标，便于系统 tint 着色。
- (UIImage *)templateImageNamed:(NSString *)name {
    return [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

// 调用方：viewDidLoad；作用：统一设置每个导航控制器的导航栏颜色和标题样式。
- (void)styleNavigationController:(UINavigationController *)navigationController {
    navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    navigationController.navigationBar.tintColor = [self colorWithHex:0x0F766E];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: [self colorWithHex:0x111827],
        NSFontAttributeName: [UIFont boldSystemFontOfSize:18]
    };
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.shadowColor = [UIColor clearColor];
        appearance.titleTextAttributes = navigationController.navigationBar.titleTextAttributes;
        navigationController.navigationBar.standardAppearance = appearance;
        navigationController.navigationBar.scrollEdgeAppearance = appearance;
        navigationController.navigationBar.compactAppearance = appearance;
    }
}

// 调用方：viewDidLoad；作用：配置 iOS 13+ TabBar 外观，避免滚动边缘状态变色。
- (void)configureBarAppearances {
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *tabAppearance = [[UITabBarAppearance alloc] init];
        [tabAppearance configureWithOpaqueBackground];
        tabAppearance.backgroundColor = [UIColor whiteColor];
        self.tabBar.standardAppearance = tabAppearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = tabAppearance;
        }
    }
}

// 调用方：本控制器样式配置；作用：把十六进制色值转换成 UIColor。
- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
