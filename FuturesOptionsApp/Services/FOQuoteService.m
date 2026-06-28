#import "FOQuoteService.h"
#import "FOContract.h"

@implementation FOQuoteService

// 调用方：行情页 refreshQuotes 和自选页 reloadWatchlist；作用：请求新浪行情接口并返回合约行情。
- (void)fetchQuotesForContracts:(NSArray<FOContract *> *)contracts completion:(FOQuoteCompletion)completion {
    NSArray<FOContract *> *futureContracts = [contracts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FOContract *contract, NSDictionary *bindings) {
        return contract.kind == FOContractKindFuture && contract.symbol.length > 0;
    }]];
    
    if (futureContracts.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(@[], nil);
        });
        return;
    }
    
    NSMutableArray<NSString *> *symbols = [NSMutableArray array];
    for (FOContract *contract in futureContracts) {
        [symbols addObject:contract.symbol];
    }
    
    NSString *symbolList = [symbols componentsJoinedByString:@","];
    NSString *urlText = [NSString stringWithFormat:@"https://hq.sinajs.cn/list=%@", symbolList];
    NSURL *url = [NSURL URLWithString:urlText];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10;
    [request setValue:@"https://finance.sina.com.cn/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"Mozilla/5.0 iPhone FuturesOptionsApp" forHTTPHeaderField:@"User-Agent"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@[], error);
            });
            return;
        }
        
        NSStringEncoding gbEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *payload = [[NSString alloc] initWithData:data encoding:gbEncoding];
        if (payload.length == 0) {
            payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        NSArray<FOContract *> *parsed = [self parsedContractsFromPayload:payload baseContracts:futureContracts];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(parsed, nil);
        });
    }];
    [task resume];
}

// 调用方：fetchQuotesForContracts 的网络回调；作用：解析新浪返回文本并生成行情合约数组。
- (NSArray<FOContract *> *)parsedContractsFromPayload:(NSString *)payload baseContracts:(NSArray<FOContract *> *)baseContracts {
    NSMutableDictionary<NSString *, FOContract *> *baseBySymbol = [NSMutableDictionary dictionary];
    for (FOContract *contract in baseContracts) {
        baseBySymbol[contract.symbol] = contract;
    }
    
    NSMutableArray<FOContract *> *results = [NSMutableArray array];
    NSArray<NSString *> *lines = [payload componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"var hq_str_([^=]+)=\\\"([^\\\"]*)\\\";" options:0 error:nil];
    
    for (NSString *line in lines) {
        NSTextCheckingResult *match = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (match.numberOfRanges < 3) {
            continue;
        }
        
        NSString *symbol = [line substringWithRange:[match rangeAtIndex:1]];
        NSString *rawFields = [line substringWithRange:[match rangeAtIndex:2]];
        FOContract *base = baseBySymbol[symbol];
        if (!base) {
            continue;
        }
        
        NSArray<NSString *> *fields = [rawFields componentsSeparatedByString:@","];
        FOContract *contract = [base copy];
        [self fillContract:contract withFields:fields];
        [results addObject:contract];
    }
    
    if (results.count == 0) {
        return baseContracts;
    }
    return results;
}

// 调用方：parsedContractsFromPayload；作用：按新浪不同字段结构填充合约价格、成交量、日期等字段。
- (void)fillContract:(FOContract *)contract withFields:(NSArray<NSString *> *)fields {
    if (fields.count == 0) {
        return;
    }
    
    BOOL firstFieldIsName = ![self isNumericString:fields.firstObject];
    if (firstFieldIsName) {
        contract.name = [self nonEmpty:fields[0] fallback:contract.name];
        contract.lastPrice = [self fieldAtIndex:8 fields:fields fallback:[self fieldAtIndex:7 fields:fields fallback:@"--"]];
        contract.volumeText = [self fieldAtIndex:13 fields:fields fallback:@"--"];
        contract.tradingDay = [self fieldAtIndex:17 fields:fields fallback:@"--"];
        contract.settlementText = [self fieldAtIndex:10 fields:fields fallback:@"--"];
        contract.quoteTime = [self fieldAtIndex:1 fields:fields fallback:@"--"];
        [self fillChangeForContract:contract lastIndex:8 previousIndex:10 fields:fields];
    } else {
        contract.lastPrice = [self fieldAtIndex:3 fields:fields fallback:@"--"];
        contract.volumeText = [self fieldAtIndex:4 fields:fields fallback:@"--"];
        contract.settlementText = [self fieldAtIndex:7 fields:fields fallback:@"--"];
        contract.tradingDay = [self fieldAtIndex:37 fields:fields fallback:@"--"];
        contract.quoteTime = [self fieldAtIndex:38 fields:fields fallback:@"--"];
        contract.name = [self fieldAtIndex:41 fields:fields fallback:contract.name];
        [self fillChangeForContract:contract lastIndex:3 previousIndex:7 fields:fields];
    }
}

// 调用方：fillContract；作用：根据最新价和昨结算计算涨跌额与涨跌幅。
- (void)fillChangeForContract:(FOContract *)contract lastIndex:(NSUInteger)lastIndex previousIndex:(NSUInteger)previousIndex fields:(NSArray<NSString *> *)fields {
    double last = [[self fieldAtIndex:lastIndex fields:fields fallback:@"0"] doubleValue];
    double previous = [[self fieldAtIndex:previousIndex fields:fields fallback:@"0"] doubleValue];
    if (last <= 0 || previous <= 0) {
        contract.changeText = @"--";
        contract.changePercentText = @"--";
        return;
    }
    
    double change = last - previous;
    double percent = change / previous * 100.0;
    contract.changeText = [NSString stringWithFormat:@"%+.2f", change];
    contract.changePercentText = [NSString stringWithFormat:@"%+.2f%%", percent];
}

// 调用方：fillContract 和 fillChangeForContract；作用：安全读取字段数组指定位置的文本。
- (NSString *)fieldAtIndex:(NSUInteger)index fields:(NSArray<NSString *> *)fields fallback:(NSString *)fallback {
    if (index >= fields.count) {
        return fallback;
    }
    return [self nonEmpty:fields[index] fallback:fallback];
}

// 调用方：fieldAtIndex 和 fillContract；作用：清理空白文本并提供默认值。
- (NSString *)nonEmpty:(NSString *)text fallback:(NSString *)fallback {
    NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmed.length > 0 ? trimmed : fallback;
}

// 调用方：fillContract；作用：判断新浪返回首字段是否为数字以区分字段格式。
- (BOOL)isNumericString:(NSString *)text {
    NSScanner *scanner = [NSScanner scannerWithString:text];
    double value = 0;
    return [scanner scanDouble:&value] && scanner.isAtEnd;
}

@end
