//
//  CustomIncomeView.m
//  TUICallKit
//
//  Created by Yuj on 2023/4/27.
//

#import "CustomIncomeView.h"
#import "UIColor+TUICallingHex.h"
#import "Masonry.h"
@interface CustomIncomeView()
@property (nonatomic,strong) UIView *container;
@property (nonatomic,strong) UIImageView *icon;
@property (nonatomic,strong) UILabel *incomeLB;
@property (nonatomic,strong) UILabel *aniLB;
@property (nonatomic,assign) NSInteger income;
@end

@implementation CustomIncomeView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initUI];
    self.clipsToBounds = false;
    self.container.hidden = true;
  }
  return self;
}
- (void)updateIncome:(NSDictionary *)param{
  if (!param || [param[@"is_free"] boolValue] || [param[@"show_fee_type"] intValue] != 2){
    self.container.hidden = true;
    return;
  }
  NSInteger total = [param[@"total_fee"] integerValue];
  self.container.hidden = total <= 0;
  self.incomeLB.text = [NSString stringWithFormat:@"收益：%ld",total];
  if (total <= 0){
    self.income = 0;
  }else{
    NSInteger add = total - self.income;
    if (add == 0){
      return;
    }
    self.income = total;
    self.aniLB.hidden = false;
    self.aniLB.alpha = 1;
    self.aniLB.text = [NSString stringWithFormat:@"+%ld",add];
    [self.aniLB mas_updateConstraints:^(MASConstraintMaker *make) {
      make.bottom.mas_equalTo(self.container.mas_top).mas_offset(10);
    }];
    [self layoutIfNeeded];
    [UIView animateWithDuration:1 animations:^{
      self.aniLB.alpha = 0;
      [self.aniLB mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.container.mas_top).mas_offset(0);
      }];
      [self layoutIfNeeded];
    } completion:^(BOOL finished) {
      self.aniLB.hidden = true;
    }];
  }
}
- (void)initUI{
  [self addSubview:self.container];
  [self.container addSubview:self.icon];
  [self.container addSubview:self.incomeLB];
  [self addSubview:self.aniLB];
  [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(0);
    make.height.mas_equalTo(24);
  }];
  [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(10);
    make.centerY.mas_equalTo(self.container);
  }];
  [self.incomeLB mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.icon.mas_right).mas_offset(6);
    make.centerY.mas_equalTo(0);
    make.right.mas_equalTo(-10);
  }];
  [self.aniLB mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(self.container).mas_offset(-10);
    make.bottom.mas_equalTo(self.container.mas_top).mas_offset(0);
  }];
  [self.container layoutIfNeeded];
}
- (UIView *)container{
  if (!_container){
    _container = [UIView new];
    _container.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
    _container.layer.cornerRadius = 12;
  }
  return _container;
}
- (UIImageView *)icon{
  if (!_icon){
    _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"income_bean"]];
  }
  return _icon;
}
- (UILabel *)incomeLB{
  if (!_incomeLB){
    _incomeLB = [UILabel new];
    _incomeLB.font = [UIFont systemFontOfSize:12];
    _incomeLB.textColor = UIColor.whiteColor;
  }
  return _incomeLB;
}
- (UILabel *)aniLB{
  if (!_aniLB){
    _aniLB = [UILabel new];
    _aniLB.font = [UIFont systemFontOfSize:10];
    _aniLB.textColor = [UIColor t_colorWithHexString:@"#F83466"];
  }
  return _aniLB;
}
@end
