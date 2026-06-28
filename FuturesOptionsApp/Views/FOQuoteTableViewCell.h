#import <UIKit/UIKit.h>

@class FOContract;

NS_ASSUME_NONNULL_BEGIN

@interface FOQuoteTableViewCell : UITableViewCell

@property (nonatomic, assign) CGFloat cardVerticalInset;

// 调用方：行情页和自选页 cellForRowAtIndexPath；作用：绑定合约行情并设置自选状态展示。
- (void)configureWithContract:(FOContract *)contract watchlisted:(BOOL)watchlisted;

@end

NS_ASSUME_NONNULL_END
