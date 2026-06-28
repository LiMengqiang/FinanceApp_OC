#import "FOWatchlistStore.h"

static NSString * const FOWatchlistSymbolsKey = @"FOWatchlistSymbolsKey";

@implementation FOWatchlistStore

// 调用方：行情页和自选页；作用：提供全局唯一的自选存储对象。
+ (instancetype)sharedStore {
    static FOWatchlistStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[FOWatchlistStore alloc] init];
    });
    return store;
}

// 调用方：自选页 reloadWatchlist 和内部判断方法；作用：读取 NSUserDefaults 中的自选列表。
- (NSArray<NSString *> *)symbols {
    NSArray *saved = [[NSUserDefaults standardUserDefaults] arrayForKey:FOWatchlistSymbolsKey];
    if (![saved isKindOfClass:[NSArray class]]) {
        return @[];
    }
    return saved;
}

// 调用方：行情 Cell 配置和 toggleSymbol；作用：判断指定合约是否在自选列表中。
- (BOOL)containsSymbol:(NSString *)symbol {
    return [[self symbols] containsObject:symbol];
}

// 调用方：toggleSymbol 或外部自选管理；作用：追加保存一个自选 symbol。
- (void)addSymbol:(NSString *)symbol {
    if (symbol.length == 0 || [self containsSymbol:symbol]) {
        return;
    }
    NSMutableArray<NSString *> *symbols = [[self symbols] mutableCopy];
    [symbols addObject:symbol];
    [self saveSymbols:symbols];
}

// 调用方：自选页删除和 toggleSymbol；作用：删除并保存自选 symbol。
- (void)removeSymbol:(NSString *)symbol {
    NSMutableArray<NSString *> *symbols = [[self symbols] mutableCopy];
    [symbols removeObject:symbol];
    [self saveSymbols:symbols];
}

// 调用方：行情页 didSelectRowAtIndexPath；作用：点选合约时添加或取消自选。
- (void)toggleSymbol:(NSString *)symbol {
    if ([self containsSymbol:symbol]) {
        [self removeSymbol:symbol];
    } else {
        [self addSymbol:symbol];
    }
}

// 调用方：addSymbol 和 removeSymbol；作用：把自选列表写入 NSUserDefaults。
- (void)saveSymbols:(NSArray<NSString *> *)symbols {
    [[NSUserDefaults standardUserDefaults] setObject:symbols forKey:FOWatchlistSymbolsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
