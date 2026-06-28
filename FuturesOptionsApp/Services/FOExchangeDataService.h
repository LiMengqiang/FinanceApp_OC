#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FOExchangeDataService : NSObject

// 调用方：我的页；作用：提供各交易所公开数据入口。
+ (NSArray<NSDictionary<NSString *, NSString *> *> *)exchangeLinks;
// 调用方：交易所数据服务调用方；作用：生成上期所指定日期日行情 URL。
+ (NSURL *)shfeDailyDataURLForDate:(NSDate *)date;
// 调用方：后续日行情页面或数据同步逻辑；作用：请求并解析上期所指定日期日行情数据。
+ (void)fetchSHFEDailyRowsForDate:(NSDate *)date completion:(void (^)(NSArray<NSDictionary *> *rows, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
