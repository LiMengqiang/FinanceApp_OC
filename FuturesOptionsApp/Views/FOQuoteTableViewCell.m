#import "FOQuoteTableViewCell.h"
#import "FOContract.h"

@interface FOQuoteTableViewCell ()

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *changeLabel;

@end

@implementation FOQuoteTableViewCell

// 调用方：UITableView 创建 Cell；作用：初始化行情卡片及内部标签样式。
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cardVerticalInset = 5.0;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _cardView = [[UIView alloc] initWithFrame:CGRectZero];
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 8;
        _cardView.layer.masksToBounds = YES;
        [self.contentView addSubview:_cardView];
        
        _nameLabel = [self labelWithFont:[UIFont boldSystemFontOfSize:16] color:[self colorWithHex:0x111827] alignment:NSTextAlignmentLeft];
        _metaLabel = [self labelWithFont:[UIFont systemFontOfSize:12] color:[self colorWithHex:0x6B7280] alignment:NSTextAlignmentLeft];
        _priceLabel = [self labelWithFont:[UIFont monospacedDigitSystemFontOfSize:18 weight:UIFontWeightSemibold] color:[self colorWithHex:0x111827] alignment:NSTextAlignmentRight];
        _changeLabel = [self labelWithFont:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold] color:[UIColor whiteColor] alignment:NSTextAlignmentCenter];
        
        _changeLabel.layer.cornerRadius = 4;
        _changeLabel.layer.masksToBounds = YES;
        
        [_cardView addSubview:_nameLabel];
        [_cardView addSubview:_metaLabel];
        [_cardView addSubview:_priceLabel];
        [_cardView addSubview:_changeLabel];
    }
    return self;
}

// 调用方：initWithStyle；作用：按统一字体、颜色和对齐方式创建标签。
- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = font;
    label.textColor = color;
    label.textAlignment = alignment;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return label;
}

// 调用方：UIKit 布局流程；作用：计算行情卡片内各标签位置，避免内容重叠。
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat marginX = 12;
    CGFloat marginY = self.cardVerticalInset;
    self.cardView.frame = CGRectMake(marginX, marginY, CGRectGetWidth(self.contentView.bounds) - marginX * 2, CGRectGetHeight(self.contentView.bounds) - marginY * 2);
    
    CGFloat cardWidth = CGRectGetWidth(self.cardView.bounds);
    CGFloat cardHeight = CGRectGetHeight(self.cardView.bounds);
    CGFloat padding = 14;
    CGFloat rightWidth = 112;
    CGFloat leftWidth = cardWidth - padding * 2 - rightWidth - 12;
    
    self.nameLabel.frame = CGRectMake(padding, 12, leftWidth, 22);
    self.metaLabel.frame = CGRectMake(padding, 36, leftWidth, 18);
    self.priceLabel.frame = CGRectMake(cardWidth - padding - rightWidth, 10, rightWidth, 24);
    self.changeLabel.frame = CGRectMake(cardWidth - padding - 76, 37, 76, 22);
}

// 调用方：行情页和自选页 cellForRowAtIndexPath；作用：把合约数据渲染到行情 Cell。
- (void)configureWithContract:(FOContract *)contract watchlisted:(BOOL)watchlisted {
    NSString *prefix = watchlisted ? @"★ " : @"";
    self.nameLabel.text = [NSString stringWithFormat:@"%@%@", prefix, contract.name ?: @"--"];
    self.metaLabel.text = [NSString stringWithFormat:@"%@ · %@ · 量%@", contract.symbol ?: @"--", contract.exchange ?: @"--", contract.volumeText ?: @"--"];
    self.priceLabel.text = contract.lastPrice ?: @"--";
    self.changeLabel.text = contract.changePercentText ?: @"--";
    
    UIColor *upColor = [self colorWithHex:0xD93025];
    UIColor *downColor = [self colorWithHex:0x188038];
    UIColor *flatColor = [self colorWithHex:0x6B7280];
    
    double change = [contract.changeText doubleValue];
    UIColor *trendColor = flatColor;
    if (change > 0) {
        trendColor = upColor;
    } else if (change < 0) {
        trendColor = downColor;
    }
    
    self.priceLabel.textColor = trendColor;
    self.changeLabel.backgroundColor = trendColor;
}

// 调用方：本类样式配置；作用：把十六进制色值转换成 UIColor。
- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
