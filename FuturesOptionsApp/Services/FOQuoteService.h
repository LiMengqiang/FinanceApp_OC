#import <Foundation/Foundation.h>

@class FOContract;

NS_ASSUME_NONNULL_BEGIN

typedef void (^FOQuoteCompletion)(NSArray<FOContract *> *contracts, NSError *_Nullable error);

@interface FOQuoteService : NSObject

// 调用方：行情页和自选页；作用：批量请求新浪期货行情并回调解析后的合约列表。
- (void)fetchQuotesForContracts:(NSArray<FOContract *> *)contracts completion:(FOQuoteCompletion)completion;

@end

NS_ASSUME_NONNULL_END
