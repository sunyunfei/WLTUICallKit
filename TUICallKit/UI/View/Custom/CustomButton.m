//
//  CustomButton.m
//  TUICallKit
//
//  Created by Yuj on 2023/4/18.
//

#import "CustomButton.h"
#import "Masonry.h"

@interface CustomButton()
@property (nonatomic,copy) NSString *named;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,strong) UIStackView *stackView;
@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *titleLB;
@end
@implementation CustomButton

- (instancetype)initWithImage:(NSString *)named title:(NSString *)title{
  if (self = [super init]){
    self.named = named;
    
    self.title = title;
    self.color = UIColor.blackColor;
    [self initUI];
  }
  return self;
}
- (instancetype)initWithImage:(NSString *)named title:(NSString *)title color:(UIColor *)color{
  if (self = [super init]){
    self.named = named;
    self.title = title;
    self.color = color;
    [self initUI];
  }
  return self;
}
- (void)updateImage:(UIImage *)image{
  self.iconView.image = image;
}
- (void)updateTitle:(NSString *)title{
  self.titleLB.text = title;
}
- (void)updateFont:(UIFont *)font{
  self.titleLB.font = font;
}
- (void)initUI{
  self.titleLB.textColor = self.color;
  self.iconView.image = [UIImage imageNamed:self.named];
  self.titleLB.text = self.title;
  [self addSubview:self.stackView];
  [self.stackView addArrangedSubview:self.iconView];
  [self.stackView addArrangedSubview:self.titleLB];
  [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.mas_equalTo(self);
    make.width.mas_lessThanOrEqualTo(self);
  }];
}
- (UIStackView *)stackView{
  if (!_stackView){
    _stackView = [UIStackView new];
    _stackView.userInteractionEnabled = false;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.spacing = 10;
  }
  return _stackView;
}
- (UIImageView *)iconView{
  if (!_iconView){
    _iconView = [UIImageView new];
  }
  return _iconView;
}
- (UILabel *)titleLB{
  if (!_titleLB){
    _titleLB = [UILabel new];
    _titleLB.font = [UIFont systemFontOfSize:16];
  }
  return _titleLB;
}
- (UIColor *)color{
  if (!_color){
    _color = UIColor.blackColor;
  }
  return _color;
}
@end
