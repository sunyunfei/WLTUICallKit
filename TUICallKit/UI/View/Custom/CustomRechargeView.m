//
//  CustomRechargeView.m
//  TUICallKit
//
//  Created by Yuj on 2023/4/21.
//

#import "CustomRechargeView.h"
#import "Masonry.h"
#import "UIColor+TUICallingHex.h"

@interface CustomRechargeCell : UICollectionViewCell
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *icon;
@property (nonatomic,strong) UIImageView *discount;
@property (nonatomic,strong) UIStackView *stackView;
@property (nonatomic,strong) UILabel *number;
@property (nonatomic,strong) UILabel *other;
@property (nonatomic,strong) UILabel *money;

+ (NSString *)identifier;
- (void)updateSelect:(BOOL)select;
- (void)updateItems:(NSDictionary *)json;
@end

@implementation CustomRechargeCell
+ (NSString *)identifier{
  return @"CustomRechargeCell";
}
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initUI];
  }
  return self;
}
- (void)updateSelect:(BOOL)select{
  self.bgView.layer.borderWidth = select ? 1 : 0.5;
  self.bgView.layer.borderColor = select ? [UIColor t_colorWithHexString:@"#F24390"].CGColor : [UIColor t_colorWithHexString:@"#C5C5C5"].CGColor;
}
- (void)updateItems:(NSDictionary *)json{
  int amount = [json[@"amount"] intValue];
  int score = [json[@"score"] intValue];
  NSArray *gifts = json[@"gift"];
  BOOL showDiscount = [json[@"show_discount"] intValue] == 1;
  self.discount.hidden = !showDiscount;
  NSString *sendCoin = @"";
  NSString *sendTitle = @"";
  for (NSDictionary *item in gifts) {
    if ([item[@"keywords"] isEqualToString:@"gold_beans"]){
      sendCoin = [NSString stringWithFormat:@"%d",[item[@"num"] intValue]];
      sendTitle = item[@"title"];
      break;
    }
  }
  self.number.text = [NSString stringWithFormat:@"%d",score];
  self.other.text = [NSString stringWithFormat:@"送%@%@",sendCoin,sendTitle];
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%d",amount]];
  [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, att.length)];
  [att addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]} range:NSMakeRange(0, 1)];
  self.money.attributedText = att;
}
- (void)initUI{
  [self.contentView addSubview:self.bgView];
  [self.contentView addSubview:self.discount];
  [self.contentView addSubview:self.stackView];
  [self.stackView addArrangedSubview:self.number];
  [self.stackView addArrangedSubview:self.icon];
  [self.contentView addSubview:self.other];
  [self.contentView addSubview:self.money];
  [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(0);
  }];
  [self.discount mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(0);
    make.top.mas_equalTo(-8);
  }];
  [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.contentView);
    make.top.mas_equalTo(20);
  }];
  [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(12);
  }];
  [self.other mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.contentView);
    make.top.mas_equalTo(self.stackView.mas_bottom).mas_offset(20);
  }];
  [self.money mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.contentView);
    make.bottom.mas_equalTo(-8);
  }];
}
- (UIView *)bgView{
  if (!_bgView){
    _bgView = [UIView new];
    _bgView.backgroundColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
    _bgView.layer.cornerRadius = 5;
    _bgView.layer.borderWidth = 0.5;
    _bgView.layer.borderColor = [UIColor t_colorWithHexString:@"#C5C5C5"].CGColor;
  }
  return _bgView;
}
- (UIStackView *)stackView{
  if (!_stackView){
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.spacing = 6;
  }
  return _stackView;
}
- (UIImageView *)icon{
  if (!_icon){
    _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_gold"]];
  }
  return _icon;
}

- (UILabel *)money{
  if (!_money){
    _money = [UILabel new];
  }
  return _money;
}
- (UIImageView *)discount{
  if (!_discount){
    _discount = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recharge_discount"]];
  }
  return _discount;
}
- (UILabel *)number{
  if (!_number){
    _number = [UILabel new];
    _number.font = [UIFont systemFontOfSize:16];
    _number.textColor = [UIColor t_colorWithHexString:@"#2E2E2E"];
  }
  return _number;
}
- (UILabel *)other{
  if (!_other){
    _other = [UILabel new];
    _other.font = [UIFont systemFontOfSize:10];
    _other.textColor = [UIColor t_colorWithHexString:@"#FE6C62"];
  }
  return _other;
}


@end

@interface CustomRechargeView() <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIView *container;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) UIView *icon1;
@property (nonatomic,strong) UIView *icon2;
@property (nonatomic,strong) UIView *icon3;
@end

@implementation CustomRechargeView
- (NSMutableArray *)data{
  if (!_data){
    _data = NSMutableArray.array;
  }
  return _data;
}
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.index = -1;
    self.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width, 485);
    [self configUI];
    
  }
  return self;
}
- (void)rechargeEvent{
  if (self.index != -1){
    NSDictionary *item = self.data[self.index];
    NSString *productId = item[@"product_id"];
    [NSNotificationCenter.defaultCenter postNotificationName:@"flutterFunction" object:@{@"func":@"recharge",@"param":productId}];
  }
}
- (void)reloadData{
  [NSNotificationCenter.defaultCenter postNotificationName:@"flutterFunction" object:@{@"func":@"getRechargeList"}];
}
- (void)updateList:(NSArray *)data{
  self.data = data.mutableCopy;
  self.index = -1;
  [self.collectionView reloadData];
}
- (void)updateIndex{
  [self.collectionView reloadData];
  NSDictionary *item = self.data[self.index];
  NSArray *gifts = item[@"gift"];
  for (NSDictionary *item in gifts) {
    int num = [item[@"num"] intValue];
    if ([item[@"keywords"] isEqualToString:@"gold_beans"]){
      UILabel *lb = [self.icon1 viewWithTag:99];
      lb.text = [NSString stringWithFormat:@"额外撩币x%d",num];
    }else if ([item[@"keywords"] isEqualToString:@"game_prop"]){
      UILabel *lb = [self.icon2 viewWithTag:99];
      lb.text = [NSString stringWithFormat:@"姻缘卡x%d",num];
    }else if ([item[@"keywords"] isEqualToString:@"rand-box"]){
      UILabel *lb = [self.icon3 viewWithTag:99];
      lb.text = [NSString stringWithFormat:@"盲盒礼包x%d",num];
    }
  }
}
- (void)configUI{
  [self addSubview:self.topView];
  UIImageView *topBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_top"]];
  [self.topView addSubview:topBG];
  self.icon1 = [self getView:@"ic_icon1" title:@"额外撩币" tag:0];
  self.icon2 = [self getView:@"ic_icon2" title:@"姻缘卡" tag:1];
  self.icon3 = [self getView:@"ic_icon3" title:@"盲盒礼包" tag:2];
  [self.topView addSubview:self.icon1];
  [self.topView addSubview:self.icon2];
  [self.topView addSubview:self.icon3];
  
  [self addSubview:self.container];
  [self.container addSubview:self.collectionView];
  [self.container addSubview:self.btn];
  CGFloat width = UIScreen.mainScreen.bounds.size.width-32-15;
  
  UIButton *close = [UIButton new];
  [close setImage:[UIImage imageNamed:@"close"] forState:(UIControlStateNormal)];
  [close addTarget:self action:@selector(closeEvent) forControlEvents:(UIControlEventTouchUpInside)];
  [self addSubview:close];
  
  [close mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-6);
    make.top.mas_equalTo(60);
    make.width.height.mas_equalTo(44);
  }];
  [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.width.top.mas_equalTo(self);
    make.height.mas_equalTo(250);
  }];
  [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.width.bottom.mas_equalTo(self);
    make.top.mas_equalTo(self.topView.mas_bottom).mas_offset(0);
  }];
  [topBG mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(0);
  }];
  [self.icon2 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo(width/3);
    make.height.mas_equalTo(100);
    make.centerX.mas_equalTo(self.topView);
    make.bottom.mas_equalTo(-15);
  }];
  [self.icon1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.bottom.mas_equalTo(self.icon2);
    make.left.mas_equalTo(16);
  }];
  [self.icon3 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.bottom.mas_equalTo(self.icon2);
    make.right.mas_equalTo(-16);
  }];
  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.width.mas_equalTo(self.container);
    make.top.mas_equalTo(20);
    make.height.mas_equalTo(108);
  }];
  [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(16);
    make.right.mas_equalTo(-16);
    make.height.mas_equalTo(50);
    make.top.mas_equalTo(self.collectionView.mas_bottom).mas_offset(20);
  }];
}
- (void)closeEvent{
  [NSNotificationCenter.defaultCenter postNotificationName:@"flutterCallBack" object:@{@"func":@"recharge",@"param":@(false)}];
}
- (UIView *)getView:(NSString *)icon title:(NSString *)title tag:(int)tag{
  UIView *view = [UIView new];
  UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_icon_bg"]];
  [view addSubview:bg];
  UIImageView *ic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
  [bg addSubview:ic];
  UILabel *lb = [UILabel new];
  lb.font = [UIFont systemFontOfSize:11];
  lb.textColor = [UIColor t_colorWithHexString:@"#8B294A"];
  lb.text = title;
  lb.tag = 99;
  [view addSubview:lb];
  [bg mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.width.top.mas_equalTo(view);
  }];
  [ic mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.mas_equalTo(bg);
  }];
  [lb mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(view);
    make.top.mas_equalTo(bg.mas_bottom).mas_offset(10);
  }];
  view.tag = tag;
  return view;
}
- (UIView *)topView{
  if (!_topView){
    _topView = [UIView new];
  }
  return _topView;
}
- (UIView *)container{
  if (!_container){
    _container = [UIView new];
    _container.backgroundColor = UIColor.whiteColor;
  }
  return _container;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  CustomRechargeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CustomRechargeCell.identifier forIndexPath:indexPath];
  [cell updateItems:self.data[indexPath.row]];
  [cell updateSelect:indexPath.row == self.index];
  return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  if (self.index != indexPath.row){
    self.index = indexPath.row;
    [self updateIndex];
  }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.data.count;
}
- (UICollectionView *)collectionView{
  if (!_collectionView){
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(90, 108);
    layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.clipsToBounds = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.backgroundColor = UIColor.clearColor;
    [_collectionView registerClass:CustomRechargeCell.class forCellWithReuseIdentifier:CustomRechargeCell.identifier];
  }
  return _collectionView;
}
- (UIButton *)btn{
  if (!_btn){
    _btn = [UIButton new];
    _btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_btn setTitle:@"充值拿礼包" forState:(UIControlStateNormal)];
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width-32, 50);
    layer.colors = @[(__bridge id)[UIColor t_colorWithHexString:@"#FCC865"].CGColor,
                     (__bridge id)[UIColor t_colorWithHexString:@"#FF5394"].CGColor];
    layer.startPoint = CGPointZero;
    layer.endPoint = CGPointMake(1, 0);
    layer.cornerRadius = 25;
    [_btn.layer insertSublayer:layer atIndex:0];
    [_btn addTarget:self action:@selector(rechargeEvent) forControlEvents:(UIControlEventTouchUpInside)];
  }
  return _btn;
}
@end
