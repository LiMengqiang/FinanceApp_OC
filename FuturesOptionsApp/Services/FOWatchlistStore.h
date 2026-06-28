#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FOWatchlistStore : NSObject

// 调用方：行情页和自选页；作用：获取自选存储单例。
+ (instancetype)sharedStore;
// 调用方：自选页；作用：读取本地保存的自选 symbol 列表。
- (NSArray<NSString *> *)symbols;
// 调用方：行情页和自选页；作用：判断指定 symbol 是否已加入自选。
- (BOOL)containsSymbol:(NSString *)symbol;
// 调用方：外部自选管理逻辑；作用：添加指定 symbol 到本地自选。
- (void)addSymbol:(NSString *)symbol;
// 调用方：自选页删除和 toggleSymbol；作用：从本地自选移除指定 symbol。
- (void)removeSymbol:(NSString *)symbol;
// 调用方：行情页点选合约；作用：在添加和取消自选之间切换。
- (void)toggleSymbol:(NSString *)symbol;

@end

NS_ASSUME_NONNULL_END
