#import "FOWatchlistViewController.h"
#import "FOContract.h"
#import "FOQuoteService.h"
#import "FOWatchlistStore.h"
#import "../Views/FOQuoteTableViewCell.h"

@interface FOWatchlistViewController ()

@property (nonatomic, strong) FOQuoteService *quoteService;
@property (nonatomic, copy) NSArray<FOContract *> *contracts;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation FOWatchlistViewController

// 调用方：UIKit 生命周期；作用：初始化自选页刷新控件、空状态和列表样式。
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"自选";
    self.quoteService = [[FOQuoteService alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWatchlist)];
    self.view.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 74;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadWatchlist) forControlEvents:UIControlEventValueChanged];
    
    self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyLabel.text = @"暂无自选，在行情页点选合约添加";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [self colorWithHex:0x6B7280];
    self.emptyLabel.numberOfLines = 0;
}

// 调用方：UIKit 生命周期；作用：页面出现时重新读取自选并刷新行情。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadWatchlist];
}

// 调用方：页面出现、右上角刷新按钮和下拉刷新；作用：读取本地自选并请求最新行情。
- (void)reloadWatchlist {
    NSMutableArray<FOContract *> *savedContracts = [NSMutableArray array];
    for (NSString *symbol in [[FOWatchlistStore sharedStore] symbols]) {
        FOContract *contract = [FOContract defaultContractForSymbol:symbol];
        if (contract) {
            [savedContracts addObject:contract];
        }
    }
    
    if (savedContracts.count == 0) {
        self.contracts = @[];
        [self.refreshControl endRefreshing];
        [self updateEmptyState];
        [self.tableView reloadData];
        return;
    }
    
    [self.quoteService fetchQuotesForContracts:savedContracts completion:^(NSArray<FOContract *> *contracts, NSError *error) {
        [self.refreshControl endRefreshing];
        self.contracts = contracts.count > 0 ? contracts : savedContracts;
        [self updateEmptyState];
        [self.tableView reloadData];
        if (error) {
            [self showMessage:@"自选刷新失败，请稍后重试"];
        }
    }];
}

// 调用方：reloadWatchlist 和删除自选后；作用：根据自选数量显示或隐藏空状态。
- (void)updateEmptyState {
    self.tableView.backgroundView = self.contracts.count == 0 ? self.emptyLabel : nil;
}

// 调用方：UITableViewDataSource；作用：返回自选列表行数。
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contracts.count;
}

// 调用方：UITableViewDataSource；作用：创建并配置自选行情 Cell。
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FOQuoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WatchlistCell"];
    if (!cell) {
        cell = [[FOQuoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WatchlistCell"];
    }
    FOContract *contract = self.contracts[indexPath.row];
    [cell configureWithContract:contract watchlisted:YES];
    return cell;
}

// 调用方：UITableViewDelegate；作用：允许自选行左滑删除。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 调用方：UITableViewDelegate；作用：处理左滑删除并同步本地自选存储。
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    FOContract *contract = self.contracts[indexPath.row];
    [[FOWatchlistStore sharedStore] removeSymbol:contract.symbol];
    NSMutableArray<FOContract *> *mutableContracts = [self.contracts mutableCopy];
    [mutableContracts removeObjectAtIndex:indexPath.row];
    self.contracts = mutableContracts;
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateEmptyState];
}

// 调用方：reloadWatchlist 异常回调；作用：弹出简短错误提示。
- (void)showMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 调用方：本控制器样式配置；作用：把十六进制色值转换成 UIColor。
- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
