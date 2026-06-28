#import "FOExchangeDataService.h"

@implementation FOExchangeDataService

// 调用方：我的页 viewDidLoad；作用：返回交易所公开数据入口展示列表。
+ (NSArray<NSDictionary<NSString *, NSString *> *> *)exchangeLinks {
    return @[
        @{@"title": @"上期所日行情", @"subtitle": @"合约资料、结算价、成交量", @"url": @"https://www.shfe.com.cn/reports/tradedata/dailyandweeklydata/"},
        @{@"title": @"上期能源日行情", @"subtitle": @"原油等能源期货期权", @"url": @"https://www.ine.cn/reports/tradedata/dailyandweeklydata/"},
        @{@"title": @"大商所日行情", @"subtitle": @"农产品、化工等期货期权", @"url": @"http://www.dce.com.cn/dalianshangpin/xqsj/tjsj26/rtj/rxq/index.html"},
        @{@"title": @"郑商所日行情", @"subtitle": @"农产品、能源化工等期货期权", @"url": @"http://www.czce.com.cn/cn/DFSStaticFiles/Future/"},
        @{@"title": @"中金所日行情", @"subtitle": @"股指、国债及相关期权", @"url": @"https://www.cffex.com.cn/ccpm/"},
    ];
}

// 调用方：fetchSHFEDailyRowsForDate 或后续详情页；作用：拼接上期所指定日期日行情接口地址。
+ (NSURL *)shfeDailyDataURLForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *dateText = [formatter stringFromDate:date];
    NSString *urlText = [NSString stringWithFormat:@"https://www.shfe.com.cn/data/dailydata/kx/kx%@.dat", dateText];
    return [NSURL URLWithString:urlText];
}

// 调用方：后续日行情页面或数据同步逻辑；作用：请求上期所日行情 JSON 并回调当前品种数据行。
+ (void)fetchSHFEDailyRowsForDate:(NSDate *)date completion:(void (^)(NSArray<NSDictionary *> *rows, NSError *_Nullable error))completion {
    NSURL *url = [self shfeDailyDataURLForDate:date];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@[], error);
            });
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSArray *rows = [payload isKindOfClass:[NSDictionary class]] ? payload[@"o_curinstrument"] : nil;
        if (![rows isKindOfClass:[NSArray class]]) {
            rows = @[];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(rows, jsonError);
        });
    }];
    [task resume];
}

@end
