//
//  CustomUserInfoView.m
//  TUICallKit
//
//  Created by Yuj on 2023/4/20.
//

#import "CustomUserInfoView.h"
#import "UIColor+TUICallingHex.h"
#import "Masonry.h"
@interface CustomUserInfoView()
@property (nonatomic,strong) UILabel *tip;
@property (nonatomic,strong) UIButton *sex;
@property (nonatomic,strong) UILabel *info;

@end
@implementation CustomUserInfoView

- (instancetype)initWithFrame:(CGRect)frame{
  if (self = [super initWithFrame:frame]){
    [self configUI];
  }
  return self;
}
- (void)clean{
  [self updateTips:@""];
  [self updateInfo:nil];
}

- (void)updateTips:(NSString *)tip{
  self.tip.text = tip;
}
- (void)updateInfo:(NSDictionary *)json{
  if (!json){
    self.sex.hidden = true;
    self.info.text = @"";
    return;
  }
  BOOL man = [json[@"sex"] intValue] == 1;
  NSString *birth = json[@"birth"];
  NSDateFormatter *formatter = [NSDateFormatter new];
  formatter.dateFormat = @"yyyy-MM-dd";
  if (!birth || [birth isKindOfClass:NSNull.class] || [birth isEqualToString:@"<null>"]){
    birth = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-31536000*18]];
  }
  UIImage *sexIcon = [UIImage imageNamed:man ? @"man" : @"woman"];
  [self.sex setImage:sexIcon forState:(UIControlStateNormal)];
  self.sex.hidden = false;
  
  NSDate *date = [formatter dateFromString:birth];
  NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                     components:NSCalendarUnitYear
                                     fromDate:date
                                     toDate:NSDate.date
                                     options:0];
  NSInteger age = [ageComponents year];
  [self.sex setTitle:[NSString stringWithFormat:@"%ld",age] forState:(UIControlStateNormal)];
  NSMutableArray *items = NSMutableArray.array;
  NSString *city = json[@"location"];
  if (!city || [city isKindOfClass:NSNull.class] || [city isEqualToString:@"<null>"]){
    city = @"";
  }
  if (city.length > 0){
    city = [city componentsSeparatedByString:@" "].lastObject;
    [items addObject:city];
  }
  NSNumber *height = json[@"height"];
  if (!height || [height isKindOfClass:NSNull.class]){
    city = 0;
  }
  if (height > 0){
    [items addObject:[NSString stringWithFormat:@"%@cm",height]];
  }
  NSString *pro = json[@"profession"];
  if (!pro || [pro isKindOfClass:NSNull.class] || [pro isEqualToString:@"<null>"]){
    pro = @"";
  }
  if (pro.length > 0){
    [items addObject:pro];
  }
  self.info.text = [items componentsJoinedByString:@" · "];
}
- (void)configUI{
  [self addSubview:self.tip];
  [self addSubview:self.sex];
  [self addSubview:self.info];
  
  [self.tip mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.mas_equalTo(0);
  }];
  [self.sex mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo(33);
    make.height.mas_equalTo(12);
    make.left.mas_equalTo(0);
    make.top.mas_equalTo(self.tip.mas_bottom).mas_offset(10);
  }];
  [self.info mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(self.sex);
    make.left.mas_equalTo(self.sex.mas_right).mas_offset(10);
    make.bottom.mas_equalTo(0);
  }];
  
}
- (UILabel *)tip{
  if (!_tip){
    _tip = [UILabel new];
    _tip.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
    _tip.textColor = UIColor.whiteColor;
  }
  return _tip;
}
- (UIButton *)sex{
  if (!_sex){
    _sex = [UIButton new];
    _sex.hidden = true;
    _sex.titleLabel.font = [UIFont systemFontOfSize:10];
    _sex.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _sex.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _sex.backgroundColor = UIColor.whiteColor;
    [_sex setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
    _sex.layer.cornerRadius = 6;
    _sex.clipsToBounds = true;
    _sex.userInteractionEnabled = false;
  }
  return _sex;
}
- (UILabel *)info{
  if (!_info){
    _info = [UILabel new];
    _info.font = [UIFont systemFontOfSize:11];
    _info.textColor = UIColor.whiteColor;
  }
  return _info;
}

@end
