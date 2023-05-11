//
//  TUICallingWaitFunctionView.m
//  TUICalling
//
//  Created by noah on 2021/8/30.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingWaitFunctionView.h"
#import "Masonry.h"
#import "CustomButton.h"
@interface TUICallingWaitFunctionView ()

@property (nonatomic, strong) CustomButton *rejectBtn;
@property (nonatomic, strong) CustomButton *acceptBtn;

@end

@implementation TUICallingWaitFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.rejectBtn];
        [self addSubview:self.acceptBtn];
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.mas_equalTo(0);
      make.left.mas_equalTo(20);
      make.height.mas_equalTo(60);
      make.width.mas_equalTo(130);
    }];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.height.mas_equalTo(self.rejectBtn);
      make.left.mas_equalTo(self.rejectBtn.mas_right).mas_offset(10);
      make.right.mas_equalTo(-20);
    }];
}

#pragma mark - TUICallingFunctionViewProtocol

- (void)updateTextColor:(UIColor *)textColor {
//    [self.rejectBtn updateTitleColor:textColor];
//    [self.acceptBtn updateTitleColor:textColor];
}

#pragma mark - Event Action

- (void)rejectTouchEvent:(UIButton *)sender {
    [TUICallingAction reject];
}

- (void)acceptTouchEvent:(UIButton *)sender {
    [TUICallingAction accept];
}

#pragma mark - Lazy

- (CustomButton *)acceptBtn {
    if (!_acceptBtn) {
        __weak typeof(self) weakSelf = self;
      _acceptBtn = [[CustomButton alloc] initWithImage:@"ic_accept" title:@"接听" color:UIColor.whiteColor];
      _acceptBtn.backgroundColor = [UIColor t_colorWithHexString:@"#3AC89E"];
      _acceptBtn.layer.cornerRadius = 30;
      [_acceptBtn addTarget:self action:@selector(acceptTouchEvent:) forControlEvents:(UIControlEventTouchUpInside)];
//        _acceptBtn = [TUICallingControlButton createWithFrame:CGRectZero
//                                                    titleText:TUICallingLocalize(@"Demo.TRTC.Calling.answer")
//                                                 buttonAction:^(UIButton * _Nonnull sender) {
//            [weakSelf acceptTouchEvent:sender];
//        } imageSize:CGSizeMake(64, 64)];
//        [_acceptBtn updateTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
//        [_acceptBtn updateImage:[TUICallingCommon getBundleImageWithName:@"trtccalling_ic_dialing"]];
    }
    return _acceptBtn;
}

- (CustomButton *)rejectBtn {
    if (!_rejectBtn) {
        __weak typeof(self) weakSelf = self;
      _rejectBtn = [[CustomButton alloc] initWithImage:@"ic_hangup" title:@"挂断" color:UIColor.whiteColor];
      _rejectBtn.backgroundColor = [UIColor t_colorWithHexString:@"#F23D78"];
      _rejectBtn.layer.cornerRadius = 30;
      _rejectBtn.clipsToBounds = true;
      [_rejectBtn addTarget:self action:@selector(rejectTouchEvent:) forControlEvents:(UIControlEventTouchUpInside)];
//        _rejectBtn = [TUICallingControlButton createWithFrame:CGRectZero
//                                                    titleText:TUICallingLocalize(@"Demo.TRTC.Calling.decline")
//                                                 buttonAction:^(UIButton * _Nonnull sender) {
//            [weakSelf rejectTouchEvent:sender];
//        } imageSize:CGSizeMake(64, 64)];
//        [_rejectBtn updateTitleColor:[UIColor t_colorWithHexString:@"#666666"]];
//        [_rejectBtn updateImage:[TUICallingCommon getBundleImageWithName:@"ic_hangup"]];
    }
    
    return _rejectBtn;
}

@end
