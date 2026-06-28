#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FOContractKind) {
    FOContractKindFuture = 0,
    FOContractKindOption = 1
};

@interface FOContract : NSObject <NSCopying>

@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *exchange;
@property (nonatomic, assign) FOContractKind kind;
@property (nonatomic, copy) NSString *lastPrice;
@property (nonatomic, copy) NSString *changeText;
@property (nonatomic, copy) NSString *changePercentText;
@property (nonatomic, copy) NSString *volumeText;
@property (nonatomic, copy) NSString *settlementText;
@property (nonatomic, copy) NSString *tradingDay;
@property (nonatomic, copy) NSString *quoteTime;

// 调用方：模型工厂和默认合约列表；作用：创建一条基础合约对象。
+ (instancetype)contractWithSymbol:(NSString *)symbol
                              name:(NSString *)name
                          exchange:(NSString *)exchange
                              kind:(FOContractKind)kind;

// 调用方：行情页和自选页；作用：返回第一版默认展示的期货连续合约。
+ (NSArray<FOContract *> *)defaultFutures;
// 调用方：行情页期权分段；作用：返回交易所期权日行情入口列表。
+ (NSArray<FOContract *> *)defaultOptionSources;
// 调用方：自选页；作用：按 symbol 从默认期货列表中恢复合约对象。
+ (nullable FOContract *)defaultContractForSymbol:(NSString *)symbol;

@end

NS_ASSUME_NONNULL_END
