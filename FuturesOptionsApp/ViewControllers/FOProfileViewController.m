#import "FOProfileViewController.h"
#import "FOExchangeDataService.h"

@interface FOProfileViewController ()

@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSString *> *> *exchangeLinks;

@end

@implementation FOProfileViewController

// 调用方：UIKit 生命周期；作用：初始化我的页数据源说明、交易所入口和列表样式。
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    self.exchangeLinks = [FOExchangeDataService exchangeLinks];
    self.view.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 70;
}

// 调用方：UITableViewDataSource；作用：返回我的页分组数量。
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

// 调用方：UITableViewDataSource；作用：返回每个分组的数据行数量。
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return self.exchangeLinks.count;
    }
    return 1;
}

// 调用方：UITableViewDataSource；作用：返回每个分组的标题文本。
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"数据源";
    }
    if (section == 1) {
        return @"交易所公开数据";
    }
    return @"风险提示";
}

// 调用方：UITableViewDataSource；作用：创建并配置数据源、交易所入口和风险提示 Cell。
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProfileCell"];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.textColor = [self colorWithHex:0x111827];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [self colorWithHex:0x6B7280];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"新浪实时行情";
            cell.detailTextLabel.text = @"用于期货连续合约最新价、涨跌幅、成交量。";
        } else {
            cell.textLabel.text = @"交易所公开数据";
            cell.detailTextLabel.text = @"用于合约资料、结算价、历史日行情。";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 1) {
        NSDictionary<NSString *, NSString *> *item = self.exchangeLinks[indexPath.row];
        cell.textLabel.text = item[@"title"];
        cell.detailTextLabel.text = item[@"subtitle"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @"免费行情源稳定性和授权范围有限，正式上线前需要确认交易所或数据商授权。当前数据仅供学习和演示，不构成投资建议。";
        cell.detailTextLabel.text = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

// 调用方：UITableViewDelegate；作用：点击交易所入口时用系统浏览器打开对应网页。
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != 1) {
        return;
    }
    
    NSString *urlText = self.exchangeLinks[indexPath.row][@"url"];
    NSURL *url = [NSURL URLWithString:urlText];
    if (!url) {
        return;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:url options:@{} completionHandler:nil];
    } else {
        [application openURL:url];
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
