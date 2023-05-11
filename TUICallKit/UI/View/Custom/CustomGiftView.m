//
//  CustomGiftView.m
//  TUICallKit
//
//  Created by Yuj on 2023/4/21.
//

#import "CustomGiftView.h"
#import "Masonry.h"
#import "UIColor+TUICallingHex.h"
#import "SDWebImage.h"

@interface CustomGiftCell : UICollectionViewCell
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *icon;
@property (nonatomic,strong) UILabel *name;
@property (nonatomic,strong) UILabel *money;
+ (NSString *)identifier;
- (void)updateItem:(NSDictionary *)item;
@end

@implementation CustomGiftCell
+ (NSString *)identifier{
  return @"CustomGiftCell";
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
  self.bgView.backgroundColor = select ? [UIColor t_colorWithHexString:@"#F2F2F2"] : UIColor.clearColor;
}
- (void)updateItem:(NSDictionary *)item{
  if (item){
    self.bgView.backgroundColor = UIColor.clearColor;
    NSString *path = item[@"icon_url"];
    if (!path || [path isKindOfClass:NSNull.class] || [path isEqualToString:@"<null>"]){
      path = @"";
    }
    int number = [item[@"beans"] intValue];
    int type = [item[@"buy_type"] intValue];
    NSString *sufix = @"";
    switch (type) {
      case 1:
        sufix = @"爱意";
        break;
      case 2:
        sufix = @"恋爱豆";
        break;
      case 3:
        sufix = @"能量";
        break;
      case 4:
        sufix = @"撩币";
        break;
      case 5:
        sufix = @"金豆";
        break;
      default:
        break;
    }
    NSURL *url = [NSURL URLWithString:path];
    [self.icon sd_setImageWithURL:url];
    self.name.text = item[@"title"];
    self.money.text = [NSString stringWithFormat:@"%d%@",number,sufix];
  }else{
    self.bgView.backgroundColor = UIColor.clearColor;
    self.icon.image = nil;
    self.name.text = @"";
    self.money.text = @"";
  }
}
- (void)initUI{
  [self.contentView addSubview:self.bgView];
  [self.contentView addSubview:self.icon];
  [self.contentView addSubview:self.name];
  [self.contentView addSubview:self.money];
  [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(0);
  }];
  [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(60);
    make.centerX.top.mas_equalTo(self.contentView);
  }];
  [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.contentView);
    make.top.mas_equalTo(self.icon.mas_bottom).mas_offset(2);
  }];
  [self.money mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.contentView);
    make.top.mas_equalTo(self.name.mas_bottom).mas_offset(5);
  }];
}
- (UIView *)bgView{
  if (!_bgView){
    _bgView = [UIView new];
    _bgView.layer.cornerRadius = 5;
  }
  return _bgView;
}
- (UIImageView *)icon{
  if (!_icon){
    _icon = [UIImageView new];
  }
  return _icon;
}
- (UILabel *)name{
  if (!_name){
    _name = [UILabel new];
    _name.font = [UIFont systemFontOfSize:11];
    _name.textColor = [UIColor t_colorWithHexString:@"#2E2E2E"];
  }
  return _name;
}
- (UILabel *)money{
  if (!_money){
    _money = [UILabel new];
    _money.font = [UIFont systemFontOfSize:10];
    _money.textColor = [[UIColor t_colorWithHexString:@"#2E2E2E"] colorWithAlphaComponent:0.4];
  }
  return _money;
}
@end

@interface CustomGiftView() <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIStackView *stackView;
@property (nonatomic,strong) UILabel *money;
@property (nonatomic,strong) UIButton *recharge;
@property (nonatomic,strong) UIButton *send;
@property (nonatomic,strong) UIPageControl *page;
@property (nonatomic,strong) UILabel *tip;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) int gold;

@end

@implementation CustomGiftView
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
    self.gold = -1;
    self.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width, 338);
    self.backgroundColor = UIColor.whiteColor;
    
    [self initUI];
  }
  return self;
}
- (void)reloadData{
  [NSNotificationCenter.defaultCenter postNotificationName:@"flutterFunction" object:@{@"func":@"getGiftList"}];
  [NSNotificationCenter.defaultCenter postNotificationName:@"flutterFunction" object:@{@"func":@"getGold"}];
  self.index = -1;
  [self.collectionView reloadData];
}
- (void)updateList:(NSArray *)data{
  self.data = data.mutableCopy;
  self.page.numberOfPages = (data.count + 7)/8;
  self.page.currentPage = 0;
  [self.collectionView reloadData];
  self.collectionView.contentOffset = CGPointZero;
}
- (void)updateGold:(int)num{
  self.gold = num;
  self.money.text = [NSString stringWithFormat:@"%d",num];
}
- (void)closeEvent{
  [NSNotificationCenter.defaultCenter postNotificationName:@"flutterCallBack" object:@{@"func":@"gift",@"param":@(false)}];
}
- (void)rechargeEvent{
  [self closeEvent];
  [NSNotificationCenter.defaultCenter postNotificationName:@"flutterCallBack" object:@{@"func":@"recharge",@"param":@(true)}];
}
- (void)sendEvent{
  if (self.index != -1 && self.manager){
    NSDictionary *item = self.data[self.index];
    NSNumber *giftId = item[@"id"];
    [NSNotificationCenter.defaultCenter postNotificationName:@"flutterFunction" object:@{@"func":@"sendGift",@"param":@{@"id":giftId,@"num":@(1),@"userId":@(self.manager.userId)}}];
  }
}
- (void)initUI{
  UILabel *titleLB = [UILabel new];
  titleLB.font = [UIFont systemFontOfSize:16 weight:(UIFontWeightMedium)];
  titleLB.text = @"礼物";
  [self addSubview:titleLB];
  UIButton *close = [UIButton new];
  [close setImage:[UIImage imageNamed:@"close"] forState:(UIControlStateNormal)];
  [close addTarget:self action:@selector(closeEvent) forControlEvents:(UIControlEventTouchUpInside)];
  [self addSubview:close];
  [self addSubview:self.collectionView];
  [self addSubview:self.page];
  UIView *bg = [UIView new];
  bg.backgroundColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
  bg.layer.cornerRadius = 11.5;
  [self addSubview:bg];
  [self addSubview:self.stackView];
  UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_gold"]];
  [self.stackView addArrangedSubview:icon];
  [self.stackView addArrangedSubview:self.money];
  [self.stackView addArrangedSubview:self.recharge];
  [self addSubview:self.tip];
  [self addSubview:self.send];
  
  [titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(16);
    make.top.mas_equalTo(20);
  }];
  [close mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-6);
    make.centerY.mas_equalTo(titleLB);
    make.width.height.mas_equalTo(44);
  }];
  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(16);
    make.right.mas_equalTo(-16);
    make.top.mas_equalTo(titleLB.mas_bottom).mas_offset(20);
    make.height.mas_equalTo(202);
  }];
  [self.page mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.collectionView);
    make.top.mas_equalTo(self.collectionView.mas_bottom).mas_offset(5);
  }];
  [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(16);
    make.bottom.mas_equalTo(-22);
  }];
  [icon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.centerY.mas_equalTo(self.stackView);
    make.width.height.mas_equalTo(16);
  }];
  [self.money mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(self.stackView);
  }];
  [self.recharge mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(self.stackView);
    make.width.height.mas_equalTo(23);
  }];
  [bg mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(23);
    make.left.mas_equalTo(self.stackView).mas_offset(-5);
    make.right.centerY.mas_equalTo(self.stackView);
  }];
  [self.tip mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(bg);
    make.left.mas_equalTo(bg.mas_right).mas_offset(10);
  }];
  [self.send mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-16);
    make.centerY.mas_equalTo(self.stackView);
    make.width.mas_equalTo(70);
    make.height.mas_equalTo(30);
  }];
  
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  CustomGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CustomGiftCell.identifier forIndexPath:indexPath];
  [cell updateItem:indexPath.row < self.data.count ? self.data[indexPath.row] : nil];
  [cell updateSelect:self.index == indexPath.row];
  return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  if (self.index != indexPath.row && indexPath.row < self.data.count){
    self.index = indexPath.row;
    [self.collectionView reloadData];
    int number = [self.data[indexPath.row][@"beans"] intValue];
    self.tip.hidden = self.gold == -1 || self.gold > number;
  }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  int page = round(scrollView.contentOffset.x / scrollView.frame.size.width);
  self.page.currentPage =  page;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  NSInteger line = self.data.count / 8;
  int count = self.data.count % 8;
  if (count > 0){
    line += 1;
  }
  return line * 8;
}
- (UICollectionView *)collectionView{
  if (!_collectionView){
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 96);
    layout.minimumLineSpacing = (UIScreen.mainScreen.bounds.size.width-32-320)/4;
    layout.minimumInteritemSpacing = 10;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = true;
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.backgroundColor = UIColor.clearColor;
    [_collectionView registerClass:CustomGiftCell.class forCellWithReuseIdentifier:CustomGiftCell.identifier];
  }
  return _collectionView;
}
- (UIPageControl *)page{
  if (!_page){
    _page = [UIPageControl new];
    _page.pageIndicatorTintColor = [UIColor t_colorWithHexString:@"#F4F6FB"];
    _page.currentPageIndicatorTintColor = [UIColor t_colorWithHexString:@"#7774F7"];
    _page.userInteractionEnabled = false;
  }
  return _page;
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
- (UILabel *)money{
  if (!_money){
    _money = [UILabel new];
    _money.font = [UIFont systemFontOfSize:12];
  }
  return _money;
}
- (UIButton *)recharge{
  if (!_recharge){
    _recharge = [UIButton new];
    [_recharge setImage:[UIImage imageNamed:@"ic_add"] forState:(UIControlStateNormal)];
    [_recharge addTarget:self action:@selector(rechargeEvent) forControlEvents:(UIControlEventTouchUpInside)];
  }
  return _recharge;
}
- (UIButton *)send{
  if (!_send){
    _send = [UIButton new];
    _send.titleLabel.font = [UIFont systemFontOfSize:14];
    _send.backgroundColor = [UIColor t_colorWithHexString:@"#7774F7"];
    _send.layer.cornerRadius = 15;
    [_send setTitle:@"赠送" forState:(UIControlStateNormal)];
    [_send addTarget:self action:@selector(sendEvent) forControlEvents:(UIControlEventTouchUpInside)];
  }
  return _send;
}
- (UILabel *)tip{
  if (!_tip){
    _tip = [UILabel new];
    _tip.font = [UIFont systemFontOfSize:12];
    _tip.textColor = [UIColor t_colorWithHexString:@"#EA2F64"];
    _tip.text = @"余额不足请及时充值";
    _tip.hidden = true;
  }
  return _tip;
}
@end
