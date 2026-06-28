#import "FOMarketViewController.h"
#import "FOContract.h"
#import "FOQuoteService.h"
#import "FOWatchlistStore.h"
#import "../Views/FOQuoteTableViewCell.h"

@interface FOMarketViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) FOQuoteService *quoteService;
@property (nonatomic, copy) NSArray<FOContract *> *futures;
@property (nonatomic, copy) NSArray<FOContract *> *optionSources;
@property (nonatomic, copy) NSArray<FOContract *> *displayContracts;

@end

@implementation FOMarketViewController

// 调用方：UIKit 生命周期；作用：初始化行情页数据、分段控件、刷新控件和列表样式。
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"行情";
    self.quoteService = [[FOQuoteService alloc] init];
    self.futures = [FOContract defaultFutures];
    self.optionSources = [FOContract defaultOptionSources];
    self.displayContracts = self.futures;
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"期货", @"期权"]];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshQuotes)];
    self.view.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 64;
    self.tableView.tableHeaderView = [self makeHeaderView];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshQuotes) forControlEvents:UIControlEventValueChanged];
    
    [self refreshQuotes];
}

// 调用方：viewDidLoad；作用：创建行情页顶部标题和数据源更新时间区域。
- (UIView *)makeHeaderView {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 72)];
    header.backgroundColor = [self colorWithHex:0xF3F6FA];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 220, 24)];
    titleLabel.text = @"期货期权行情";
    titleLabel.font = [UIFont boldSystemFontOfSize:21];
    titleLabel.textColor = [self colorWithHex:0x111827];
    [header addSubview:titleLabel];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, 320, 18)];
    self.statusLabel.text = @"新浪实时行情 · 交易所公开数据";
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textColor = [self colorWithHex:0x6B7280];
    [header addSubview:self.statusLabel];
    
    return header;
}

// 调用方：UIKit 生命周期；作用：页面出现时刷新自选勾选状态。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

// 调用方：期货/期权分段控件；作用：切换当前展示的行情列表类型。
- (void)segmentChanged:(UISegmentedControl *)sender {
    self.displayContracts = sender.selectedSegmentIndex == 0 ? self.futures : self.optionSources;
    [self.tableView reloadData];
    if (sender.selectedSegmentIndex == 0) {
        [self refreshQuotes];
    }
}

// 调用方：右上角刷新按钮、下拉刷新和分段切换；作用：请求并刷新新浪期货行情。
- (void)refreshQuotes {
    if (self.segmentedControl.selectedSegmentIndex != 0) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self.quoteService fetchQuotesForContracts:self.futures completion:^(NSArray<FOContract *> *contracts, NSError *error) {
        [self.refreshControl endRefreshing];
        if (contracts.count > 0) {
            self.futures = contracts;
            self.displayContracts = contracts;
            self.statusLabel.text = [NSString stringWithFormat:@"新浪实时行情 · 已更新 %@", [self currentTimeText]];
            [self.tableView reloadData];
        }
        if (error) {
            [self showMessage:@"行情刷新失败，请稍后重试"];
        }
    }];
}

// 调用方：UITableViewDataSource；作用：返回当前行情列表行数。
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayContracts.count;
}

// 调用方：UITableViewDataSource；作用：根据合约类型创建并配置行情或期权入口 Cell。
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FOContract *contract = self.displayContracts[indexPath.row];
    
    if (contract.kind == FOContractKindFuture) {
        FOQuoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuoteCell"];
        if (!cell) {
            cell = [[FOQuoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QuoteCell"];
        }
        cell.cardVerticalInset = 2.5;
        [cell configureWithContract:contract watchlisted:[[FOWatchlistStore sharedStore] containsSymbol:contract.symbol]];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OptionCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [self colorWithHex:0x6B7280];
    }
    cell.textLabel.text = contract.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · 交易所公开日行情入口", contract.exchange];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

// 调用方：UITableViewDelegate；作用：期货行切换自选，期权行跳转到我的页交易所入口。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FOContract *contract = self.displayContracts[indexPath.row];
    
    if (contract.kind == FOContractKindFuture) {
        [[FOWatchlistStore sharedStore] toggleSymbol:contract.symbol];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tabBarController setSelectedIndex:2];
    }
}

// 调用方：refreshQuotes 异常回调；作用：弹出简短错误提示。
- (void)showMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 调用方：refreshQuotes 成功回调；作用：生成行情状态栏的当前更新时间文本。
- (NSString *)currentTimeText {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}

// 调用方：本控制器样式配置；作用：把十六进制色值转换成 UIColor。
- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
