#import "FOContract.h"

@implementation FOContract

// 调用方：defaultFutures 和 defaultOptionSources；作用：创建并初始化合约基础字段。
+ (instancetype)contractWithSymbol:(NSString *)symbol
                              name:(NSString *)name
                          exchange:(NSString *)exchange
                              kind:(FOContractKind)kind {
    FOContract *contract = [[FOContract alloc] init];
    contract.symbol = symbol;
    contract.name = name;
    contract.exchange = exchange;
    contract.kind = kind;
    contract.lastPrice = @"--";
    contract.changeText = @"--";
    contract.changePercentText = @"--";
    contract.volumeText = @"--";
    contract.settlementText = @"--";
    contract.tradingDay = @"--";
    contract.quoteTime = @"--";
    return contract;
}

// 调用方：行情页和自选页；作用：提供默认期货连续合约清单。
+ (NSArray<FOContract *> *)defaultFutures {
    return @[
        [FOContract contractWithSymbol:@"nf_SC0" name:@"上海原油连续" exchange:@"上期能源" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_AU0" name:@"沪金连续" exchange:@"上期所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_RB0" name:@"螺纹钢连续" exchange:@"上期所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_CU0" name:@"沪铜连续" exchange:@"上期所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_M0" name:@"豆粕连续" exchange:@"大商所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_Y0" name:@"豆油连续" exchange:@"大商所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_IF0" name:@"沪深300股指连续" exchange:@"中金所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_IH0" name:@"上证50股指连续" exchange:@"中金所" kind:FOContractKindFuture],
        [FOContract contractWithSymbol:@"nf_IC0" name:@"中证500股指连续" exchange:@"中金所" kind:FOContractKindFuture]
    ];
}

// 调用方：行情页期权分段；作用：提供期权公开日行情入口清单。
+ (NSArray<FOContract *> *)defaultOptionSources {
    return @[
        [FOContract contractWithSymbol:@"SHFE_OPTIONS" name:@"上期所期权日行情" exchange:@"上期所" kind:FOContractKindOption],
        [FOContract contractWithSymbol:@"DCE_OPTIONS" name:@"大商所期权日行情" exchange:@"大商所" kind:FOContractKindOption],
        [FOContract contractWithSymbol:@"CZCE_OPTIONS" name:@"郑商所期权日行情" exchange:@"郑商所" kind:FOContractKindOption],
        [FOContract contractWithSymbol:@"CFFEX_OPTIONS" name:@"中金所期权日行情" exchange:@"中金所" kind:FOContractKindOption]
    ];
}

// 调用方：自选页 reloadWatchlist；作用：根据已保存 symbol 找回默认合约对象。
+ (nullable FOContract *)defaultContractForSymbol:(NSString *)symbol {
    for (FOContract *contract in [self defaultFutures]) {
        if ([contract.symbol isEqualToString:symbol]) {
            return contract;
        }
    }
    return nil;
}

// 调用方：行情解析服务；作用：复制基础合约并填充最新行情，避免修改原对象。
- (id)copyWithZone:(NSZone *)zone {
    FOContract *copy = [[[self class] allocWithZone:zone] init];
    copy.symbol = self.symbol;
    copy.name = self.name;
    copy.exchange = self.exchange;
    copy.kind = self.kind;
    copy.lastPrice = self.lastPrice;
    copy.changeText = self.changeText;
    copy.changePercentText = self.changePercentText;
    copy.volumeText = self.volumeText;
    copy.settlementText = self.settlementText;
    copy.tradingDay = self.tradingDay;
    copy.quoteTime = self.quoteTime;
    return copy;
}

@end
