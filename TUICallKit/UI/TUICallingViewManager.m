//
//  TUICallingViewManager.m
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingViewManager.h"
#import "BaseCallViewProtocol.h"
#import "TUICallingGroupView.h"
#import "TUICallingSingleView.h"
#import "BaseUserViewProtocol.h"
#import "TUICallingUserView.h"
#import "TUICallingSingleVideoUserView.h"
#import "BaseFunctionViewProtocol.h"
#import "TUICallingWaitFunctionView.h"
#import "TUICallingAudioFunctionView.h"
#import "TUICallingVideoFunctionView.h"
#import "TUICallingVideoInviteFunctionView.h"
#import "TUICallingSwitchToAudioView.h"
#import "TUICallingTimerView.h"
#import "TUICallingVideoRenderView.h"
#import "UIWindow+TUICalling.h"
#import "Masonry.h"
#import "UIColor+TUICallingHex.h"
#import "TUICallingAction.h"
#import "TUICallingCalleeView.h"
#import "TUICallingFloatingWindowManager.h"
#import "TUICallingUserManager.h"
#import "TUIDefine.h"
#import "TUICallingUserModel.h"
#import "TUICallEngineHeader.h"
#import "TUICore.h"
#import "TUICallingNavigationController.h"
#import "CustomUserInfoView.h"
#import "CustomGiftView.h"
#import "CustomRechargeView.h"
#import "CustomMinuteCostView.h"
#import "CustomIncomeView.h"
#import "Lottie.h"

static NSString * const TUICallKit_TUIGroupService_UserDataValue = @"TUICallKit";

@interface TUICallingViewManager () <TUICallingFloatingWindowManagerDelegate, TUINotificationProtocol>

@property (nonatomic, strong) UIWindow *callingWindow;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView <BaseUserViewProtocol> *callingUserView;
@property (nonatomic, strong) UIView <BaseFunctionViewProtocol> *callingFunctionView;
@property (nonatomic, strong) UIView <BaseCallViewProtocol> *backgroundView;
@property (nonatomic, strong) TUICallingSwitchToAudioView *switchToAudioView;
@property (nonatomic, strong) TUICallingTimerView *timerView;
@property (nonatomic, strong) TUICallingCalleeView *callingCalleeView;
@property (nonatomic, strong) TUICallingVideoRenderView *localPreView;
@property (nonatomic, strong) TUICallingVideoRenderView *remotePreView;
@property (nonatomic, strong) UIButton *floatingWindowBtn;
/// Add other user button
@property (nonatomic, strong) UIButton *addOtherUserBtn;
@property (nonatomic, strong) CallingUserModel *remoteUser;
/// Is Enable FloatWindow
@property (nonatomic, assign) BOOL enableFloatWindow;
@property (nonatomic, assign) BOOL alreadyShownCallKitView;
@property (nonatomic,strong) UIImageView *userAvatarView;
@property (nonatomic,strong) CustomUserInfoView *userInfoView;
@property (nonatomic,strong) CustomGiftView *giftView;
@property (nonatomic,strong) CustomRechargeView *rechargeView;
@property (nonatomic,strong) CustomMinuteCostView *costView;
@property (nonatomic,strong) CustomIncomeView *incomeView;
@property (nonatomic,strong) LOTAnimationView *lottieView;
@property (nonatomic,strong) UILabel *tips;
@property (nonatomic,copy) NSString *playingUrl;
@property (nonatomic,assign) BOOL isRandom;
@end

@implementation TUICallingViewManager

- (instancetype)init {
    self = [super init];
    if (self) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        [[TUICallingFloatingWindowManager shareInstance] setFloatingWindowManagerDelegate:self];
        self.containerView.backgroundColor = UIColor.redColor;
        self.enableFloatWindow = NO;
      [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(flutterCallBack:) name:@"flutterCallBack" object:nil];
        [TUICore registerEvent:TUICore_TUIGroupNotify subKey:TUICore_TUIGroupNotify_SelectGroupMemberSubKey object:self];
    }
    return self;
}
- (void)flutterCallBack:(NSNotification *)noti{
  NSDictionary *json = noti.object;
  NSString *func = json[@"func"];
  if ([func isEqualToString:@"userInfo"]){
    NSDictionary *user = json[@"param"];
    NSString *path = user[@"avatar"][@"url"];
    NSString *name = user[@"name"];
    BOOL isVideo = [TUICallingStatusManager shareInstance].callMediaType == TUICallMediaTypeVideo;
    BOOL isCaller = TUICallingStatusManager.shareInstance.callRole == TUICallRoleCall;
    [self.userInfoView updateInfo:user];
    if (!path || [path isKindOfClass:NSNull.class] || [path isEqualToString:@"<null>"]){
      path = @"";
    }
    NSURL *url = [NSURL URLWithString:path];
    [self.userAvatarView sd_setImageWithURL:url];
    self.userId = [user[@"id"] intValue];
    if (!isCaller){
      [self.userInfoView updateTips:[NSString stringWithFormat:@"「%@」向你发来了%@邀请",name,isVideo ? @"视频" : @"语音"]];
    }
    
  }else if ([func isEqualToString:@"gift"]){
    BOOL isShow = [json[@"param"] boolValue];
    if (isShow){
      [self.giftView reloadData];
    }
    [self.containerView bringSubviewToFront:self.giftView];
    [UIView animateWithDuration:0.25 animations:^{
      self.giftView.mm_y = isShow ? UIScreen.mainScreen.bounds.size.height - self.giftView.frame.size.height : UIScreen.mainScreen.bounds.size.height;
    }];
  }else if ([func isEqualToString:@"recharge"]){
    BOOL isShow = [json[@"param"] boolValue];
    if (isShow){
      [self.rechargeView reloadData];
    }
    [self.containerView bringSubviewToFront:self.rechargeView];
    [UIView animateWithDuration:0.25 animations:^{
      self.rechargeView.mm_y = isShow ? UIScreen.mainScreen.bounds.size.height - self.rechargeView.frame.size.height : UIScreen.mainScreen.bounds.size.height;
    }];
  }else if ([func isEqualToString:@"giftList"]){
    NSArray *items = json[@"param"];
    [self.giftView updateList:items];
  }else if ([func isEqualToString:@"updateGold"]){
    int gold = [json[@"param"] intValue];
    [self.giftView updateGold:gold];
  }else if ([func isEqualToString:@"sendGift"]){
    NSDictionary *param = json[@"param"];
    
  }else if ([func isEqualToString:@"rechargeList"]){
    NSArray *items = json[@"param"];
    [self.rechargeView updateList:items];
  }else if ([func isEqualToString:@"costBean"]){
    NSDictionary *param = json[@"param"];
    [self.costView updateTimeInfo:param];
  }else if ([func isEqualToString:@"userIncome"]){
    NSDictionary *param = json[@"param"];
    [self.incomeView updateIncome:param];
    BOOL show = [param[@"show_fee_type"] intValue] == 1;
    int tip_minute = [param[@"fee_tips_minutes"] intValue];
    int total_minute = [param[@"fee_total_minutes"] intValue];
    BOOL need = total_minute - tip_minute <= 1;
    
    [self.callingFunctionView updateChargeStatus:!show || !need];
    
    if (show && need){
      NSString *s = @"文撩提醒您：";
      NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
      style.lineSpacing = 5;
      NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n您的撩币余额已不足%d分钟，为避免通话中断，请及时为爱充值～",s,total_minute] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:UIColor.whiteColor,NSParagraphStyleAttributeName:style}];
      [att addAttributes:@{NSForegroundColorAttributeName:[UIColor t_colorWithHexString:@"#25E093"]} range:NSMakeRange(0, s.length)];
      self.tips.attributedText = att;
    }
  }else if ([func isEqualToString:@"window"]){
    BOOL random = [json[@"param"] boolValue];
    self.isRandom = random;
  }else if ([func isEqualToString:@"playGift"]){
    NSString *path = json[@"param"];
    if (!path || [path isKindOfClass:NSNull.class] || [path isEqualToString:@"<null>"]){
      path = @"";
    }
    self.playingUrl = path;
    if (self.lottieView || path.length == 0){
      return;
    }
    self.lottieView = [[LOTAnimationView alloc] initWithContentsOfURL:[NSURL URLWithString:path]];
    self.lottieView.frame = self.containerView.bounds;
    [self.containerView addSubview:self.lottieView];
    __weak typeof(self) ws = self;
    [self.lottieView playWithCompletion:^(BOOL animationFinished) {
      [ws cleanPlayingUrl];
    }];
    [self performSelector:@selector(cleanPlayingUrl) withObject:nil afterDelay:12];
  }
}
- (void)cleanPlayingUrl{
    self.playingUrl = nil;
    [self.lottieView removeFromSuperview];
    self.lottieView = nil;
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cleanPlayingUrl) object:nil];
}
#pragma mark - Initialize Waiting View

- (void)initSingleWaitingView {
    [self clearAllSubViews];
  
  self.userInfoView.hidden = false;
  
    switch ([TUICallingStatusManager shareInstance].callMediaType) {
        case TUICallMediaTypeAudio:{
            [self initSingleAudioWaitingView];
        } break;
        case TUICallMediaTypeVideo:{
            [self initSingleVideoWaitingView];
        } break;
        case TUICallMediaTypeUnknown:
        default:
            break;
    }
}

- (void)initSingleAudioWaitingView {
    self.callingUserView = [[TUICallingUserView alloc] initWithFrame:CGRectZero];
    
    if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
        self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
      [self.userInfoView updateTips:@"正在等待对方接听~"];
    } else {
        self.callingFunctionView = [[TUICallingWaitFunctionView alloc] initWithFrame:CGRectZero];
      [self.userInfoView updateTips:@""];
    }
  [self.containerView addSubview:self.userAvatarView];
    [self.containerView addSubview:self.callingUserView];
    [self.containerView addSubview:self.callingFunctionView];
  [self.containerView addSubview:self.userInfoView];
  [self.containerView addSubview:self.costView];
  [self.containerView addSubview:self.tips];
  [self.containerView addSubview:self.incomeView];
    [self makeUserViewConstraints:75.0f];
    [self makeFunctionViewConstraints:92.0f];
    [self initMicMute:YES];
    
    if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
        [self initHandsFree:TUIAudioPlaybackDeviceEarpiece];
    } else {
        [self initHandsFree:TUIAudioPlaybackDeviceSpeakerphone];
    }
}

- (void)initSingleVideoWaitingView {
    self.backgroundView = [[TUICallingSingleView alloc] initWithFrame:self.containerView.frame
                                                         localPreView:self.localPreView
                                                        remotePreView:self.remotePreView];
    self.callingUserView = [[TUICallingSingleVideoUserView alloc] initWithFrame:CGRectZero];
    
    if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
        self.callingFunctionView = [[TUICallingVideoInviteFunctionView alloc] initWithFrame:CGRectZero];
      self.callingFunctionView.localPreView = self.localPreView;
      [self.userInfoView updateTips:@"正在等待对方接听~"];
    } else {
        self.callingFunctionView = [[TUICallingWaitFunctionView alloc] initWithFrame:CGRectZero];
      [self.userInfoView updateTips:@""];
    }
  
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.callingUserView];
//    [self.containerView addSubview:self.switchToAudioView];
    [self.containerView addSubview:self.callingFunctionView];
  [self.containerView addSubview:self.userInfoView];
  [self.containerView addSubview:self.costView];
  [self.containerView addSubview:self.tips];
  [self.containerView addSubview:self.incomeView];
    [self makeUserViewConstraints:60.f];
//    [self makeSwitchToAudioViewConstraints:8.0f];
    [self makeFunctionViewConstraints:92.0f];
    [self initHandsFree:TUIAudioPlaybackDeviceSpeakerphone];
}

- (void)initGroupWaitingView {
    [self clearAllSubViews];
    
    switch ([TUICallingStatusManager shareInstance].callRole) {
        case TUICallRoleCall:{
            self.backgroundView = [[TUICallingGroupView alloc] initWithFrame:self.containerView.frame localPreView:self.localPreView];
            [self.containerView addSubview:self.backgroundView];
            self.callingFunctionView = nil;
            if ([TUICallingStatusManager shareInstance].callMediaType == TUICallMediaTypeVideo) {
                self.callingFunctionView = [[TUICallingVideoFunctionView alloc] initWithFrame:CGRectZero];
                self.callingFunctionView.localPreView = self.localPreView;
            } else {
                self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
            }
            [self.containerView addSubview:self.callingFunctionView];
          [self.containerView addSubview:self.userInfoView];
          [self.containerView addSubview:self.costView];
            [self makeFunctionViewConstraints:190.0f];
        } break;
        case TUICallRoleCalled:{
            self.callingUserView = [[TUICallingUserView alloc] initWithFrame:CGRectZero];
            self.callingFunctionView = nil;
            self.callingFunctionView = [[TUICallingWaitFunctionView alloc] initWithFrame:CGRectZero];
            [self.containerView addSubview:self.callingUserView];
            [self.containerView addSubview:self.callingCalleeView];
            [self.containerView addSubview:self.callingFunctionView];
          [self.containerView addSubview:self.userInfoView];
          [self.containerView addSubview:self.costView];
            [self makeUserViewConstraints:75.0f];
            [self makeCallingCalleeViewConstraints];
            [self makeFunctionViewConstraints:92.0f];
        } break;
        case TUICallRoleNone:
        default:
            break;
    }
    
    [self initMicMute:YES];
    if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
        [self initAddOtherUserBtn];
    }
    [self initHandsFree:TUIAudioPlaybackDeviceSpeakerphone];
}

#pragma mark - Initialize Accept View

- (void)initSingleAcceptCallView {
  
    switch ([TUICallingStatusManager shareInstance].callMediaType) {
        case TUICallMediaTypeAudio:{
            [self initSingleAudioAcceptCallView];
            [self initMicMute:[TUICallingStatusManager shareInstance].isMicMute];
            if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCalled) {
                [self initHandsFree:TUIAudioPlaybackDeviceEarpiece];
            }
        } break;
        case TUICallMediaTypeVideo:{
            [self initSingleVideoAcceptCallView];
        } break;
        case TUICallMediaTypeUnknown:
        default:
            break;
    }
}

- (void)initSingleAudioAcceptCallView {
    if (!(self.callingUserView && [self.callingUserView isKindOfClass:[TUICallingUserView class]])) {
        [self clearCallingUserView];
        self.callingUserView = [[TUICallingUserView alloc] initWithFrame:CGRectZero];
    }
    
    if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingAudioFunctionView class]])) {
        [self clearCallingFunctionView];
        self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
    }
    [self.containerView addSubview:self.userAvatarView];
    [self.containerView addSubview:self.callingUserView];
    [self.containerView addSubview:self.timerView];
    [self.containerView addSubview:self.callingFunctionView];
    [self makeUserViewConstraints:75.0f];
    [self makeTimerViewConstraints:0.0f];
    [self makeFunctionViewConstraints:92.0f];
}

- (void)initSingleVideoAcceptCallView {
    if (!(self.backgroundView && [self.backgroundView isKindOfClass:[TUICallingSingleView class]])) {
        [self clearBackgroundView];
        self.backgroundView = [[TUICallingSingleView alloc] initWithFrame:self.containerView.frame
                                                             localPreView:self.localPreView
                                                            remotePreView:self.remotePreView];
    }
    
    if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingVideoFunctionView class]])) {
        [self clearCallingFunctionView];
        self.callingFunctionView = [[TUICallingVideoFunctionView alloc] initWithFrame:CGRectZero];
        self.callingFunctionView.localPreView = self.localPreView;
    }
    
    [self.containerView addSubview:self.backgroundView];
  [self.containerView sendSubviewToBack:self.backgroundView];
//    [self.containerView addSubview:self.switchToAudioView];
    [self.containerView addSubview:self.timerView];
    [self.containerView addSubview:self.callingFunctionView];
//    [self makeSwitchToAudioViewConstraints:0.0f];
    [self makeTimerViewConstraints:54.0f];
    [self makeFunctionViewConstraints:190.0f];
    [self initMicMute:YES];
    [self initHandsFree:TUIAudioPlaybackDeviceSpeakerphone];
}

- (void)initGroupAcceptCallView {
    [self clearCallingUserView];
    [self clearCallingCalleeView];
    
    if (!(self.backgroundView && [self.backgroundView isKindOfClass:[TUICallingGroupView class]])) {
        [self clearBackgroundView];
        self.backgroundView = [[TUICallingGroupView alloc] initWithFrame:self.containerView.frame localPreView:self.localPreView];
    }
    
    CGFloat functionViewHeight = 0.0;
    if ([TUICallingStatusManager shareInstance].callMediaType == TUICallMediaTypeVideo) {
        functionViewHeight = 190.0f;
        if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingVideoFunctionView class]])) {
            [self clearCallingFunctionView];
            self.callingFunctionView = [[TUICallingVideoFunctionView alloc] initWithFrame:CGRectZero];
            self.callingFunctionView.localPreView = self.localPreView;
        }
    } else {
        functionViewHeight = 92.0f;
        if (!(self.callingFunctionView && [self.callingFunctionView isKindOfClass:[TUICallingAudioFunctionView class]])) {
            [self clearCallingFunctionView];
            self.callingFunctionView = [[TUICallingAudioFunctionView alloc] initWithFrame:CGRectZero];
        }
    }
    
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.timerView];
    [self.containerView addSubview:self.callingFunctionView];
  [self.containerView addSubview:self.userInfoView];
  [self.containerView addSubview:self.costView];
    [self makeTimerViewConstraints:0.0f];
    [self makeFunctionViewConstraints:functionViewHeight];
    [self initMicMute:[TUICallingStatusManager shareInstance].isMicMute];
    [self initHandsFree:[TUICallingStatusManager shareInstance].audioPlaybackDevice];
    [self initAddOtherUserBtn];
}

- (void)initFloatingWindowBtn {
    if (!self.enableFloatWindow) {
        return;
    }
    [self.floatingWindowBtn removeFromSuperview];
    [self.containerView addSubview:self.floatingWindowBtn];
    [self makeFloatingWindowBtnConstraints];
    TUICallMediaType callMediaType = [TUICallingStatusManager shareInstance].callMediaType;
    TUICallScene callScene = [TUICallingStatusManager shareInstance].callScene;
    NSString *imageName = @"ic_min_window_dark";
    if ((callScene != TUICallSceneSingle) || (callMediaType == TUICallMediaTypeVideo)) {
        imageName = @"ic_min_window_white";
    }
    [self.floatingWindowBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:imageName] forState:UIControlStateNormal];
}

- (void)initMicMute:(BOOL)isMicMute {
    if (isMicMute) {
        [TUICallingAction openMicrophone];
    } else {
        [TUICallingAction closeMicrophone];
    }
}

- (void)initHandsFree:(TUIAudioPlaybackDevice)audioPlaybackDevice {
    [[TUICallEngine createInstance] selectAudioPlaybackDevice:audioPlaybackDevice];
    [TUICallingStatusManager shareInstance].audioPlaybackDevice = audioPlaybackDevice;
    [self updateAudioPlaybackDevice];
}

- (void)initAddOtherUserBtn {
    if (![TUICore getService:TUICore_TUIGroupService]) {
        return;
    }
    [self.addOtherUserBtn removeFromSuperview];
    [self.containerView addSubview:self.addOtherUserBtn];
    [self.addOtherUserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(StatusBar_Height + 3);
        make.right.equalTo(self.containerView).offset(-10);
        make.width.height.equalTo(@(32));
    }];
}

- (void)clearAllSubViews {
    [self clearCallingUserView];
    [self clearCallingFunctionView];
    [self clearSwitchToAudioView];
    [self clearTimerView];
    [self clearCallingCalleeView];
    [self clearAddOtherUserBtn];
    [self clearBackgroundView];
}

- (void)clearCallingUserView{
    if (_callingUserView != nil) {
        [self.callingUserView removeFromSuperview];
        self.callingUserView = nil;
    }
}

- (void)clearCallingFunctionView{
    if (_callingFunctionView != nil) {
        [self.callingFunctionView removeFromSuperview];
        self.callingFunctionView = nil;
    }
}

- (void)clearBackgroundView{
    if (_backgroundView != nil) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
}

- (void)clearSwitchToAudioView{
    if (_switchToAudioView != nil) {
        [self.switchToAudioView removeFromSuperview];
        self.switchToAudioView = nil;
    }
}

- (void)clearTimerView{
    if (_timerView != nil) {
        [self.timerView removeFromSuperview];
        self.timerView = nil;
    }
}

- (void)clearCallingCalleeView{
    if (_callingCalleeView != nil) {
        [self.callingCalleeView removeFromSuperview];
        self.callingCalleeView = nil;
    }
}

- (void)clearAddOtherUserBtn{
    if (_addOtherUserBtn != nil) {
        [self.addOtherUserBtn removeFromSuperview];
        self.addOtherUserBtn = nil;
    }
}

#pragma mark - View Constraints

- (void)makeUserViewConstraints:(CGFloat)topOffset {
    [self.callingUserView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(StatusBar_Height + topOffset);
        make.left.equalTo(self.containerView).offset(16);
        make.right.equalTo(self.containerView).offset(-16);
    }];
  self.callingUserView.hidden = true;
  if (self.userAvatarView.superview){
    [self.containerView sendSubviewToBack:self.userAvatarView];
    [self.userAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(0);
    }];
  }
}

- (void)makeFunctionViewConstraints:(CGFloat)height {
    [self.callingFunctionView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.left.width.mas_equalTo(self.containerView);
      make.top.mas_equalTo(self.containerView).mas_offset(StatusBar_Height);
      make.bottom.mas_equalTo(self.containerView).mas_offset(-Bottom_SafeHeight-20);
    }];
  if (self.userInfoView.superview){
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(20);
      make.bottom.mas_equalTo(self.callingFunctionView).mas_offset(-116);
    }];
    [self.tips mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.mas_equalTo(self.callingFunctionView).mas_offset(-90);
      make.left.mas_equalTo(20);
      make.right.mas_equalTo(-100);
    }];
    [self.incomeView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(20);
      make.bottom.mas_equalTo(self.tips.mas_top).mas_offset(-16);
    }];
    if (TUICallingStatusManager.shareInstance.callStatus != TUICallStatusAccept){
      [self.costView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(self.callingFunctionView).mas_offset(-90);
      }];
    }
  }
  
  
}

- (void)makeCallingCalleeViewConstraints {
    [self.callingCalleeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.containerView);
        make.height.equalTo(@(68));
        make.width.equalTo(self.containerView.mas_width);
    }];
}

- (void)makeSwitchToAudioViewConstraints:(CGFloat)bottomOffset {
    [self.switchToAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.height.equalTo(@(46));
        make.width.equalTo(self.containerView.mas_width);
        make.bottom.equalTo(self.callingFunctionView.mas_top).offset(-bottomOffset);
    }];
}

- (void)makeTimerViewConstraints:(CGFloat)bottomOffset {
    [self.timerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.height.equalTo(@(30));
        make.width.equalTo(self.containerView.mas_width);
        make.top.equalTo(self.containerView).offset(StatusBar_Height+5);
    }];
  [self.costView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.timerView);
    make.top.mas_equalTo(self.timerView.mas_bottom).mas_offset(10);
  }];
}

- (void)makeFloatingWindowBtnConstraints {
    [self.floatingWindowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(StatusBar_Height + 10);
        make.right.equalTo(self.containerView).offset(-16);
        make.width.height.equalTo(@(32));
    }];
}

#pragma mark - Public Method

- (void)createCallingView:(TUICallMediaType)callType callRole:(TUICallRole)callRole callScene:(TUICallScene)callScene {
    [TUICallingStatusManager shareInstance].callScene = callScene;
    [TUICallingStatusManager shareInstance].callRole = callRole;
    [TUICallingStatusManager shareInstance].callMediaType = callType;
    [TUICallingStatusManager shareInstance].callStatus = TUICallStatusWaiting;
}

- (void)createGroupCallingAcceptView:(TUICallMediaType)callType callRole:(TUICallRole)callRole callScene:(TUICallScene)callScene {
    [TUICallingStatusManager shareInstance].callScene = callScene;
    [TUICallingStatusManager shareInstance].callRole = callRole;
    [TUICallingStatusManager shareInstance].callMediaType = callType;
    [TUICallingStatusManager shareInstance].callStatus = TUICallStatusAccept;
    [self initGroupAcceptCallView];
    [self updateViewTextColor];
    [self initFloatingWindowBtn];
}

- (void)updateCallingView:(NSArray<CallingUserModel *> *)inviteeList sponsor:(CallingUserModel *)sponsor {
    self.remoteUser = sponsor;
    if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
        self.remoteUser = [inviteeList firstObject];
    }
    [self updateCallingUserView];
    [self updateCallingBackgroundView:sponsor];
    [self.callingCalleeView updateViewWithUserList:inviteeList];
}

- (void)updateCallingUserView {
    [self updateCallingUserView:nil];
}

- (void)updateCallingUserView:(NSString *)text {
    if (self.callingUserView && [self.callingUserView respondsToSelector:@selector(updateUserInfo:hint:)]) {
        [self.callingUserView updateUserInfo:self.remoteUser hint:text ?: [self getWaitingText]];
    }
}

- (void)updateCallingBackgroundView:(CallingUserModel *)sponsor {
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateViewWithUserList:sponsor:callType:callRole:)]) {
        [self.backgroundView updateViewWithUserList:[TUICallingUserManager allUserList]
                                            sponsor:sponsor
                                           callType:[TUICallingStatusManager shareInstance].callMediaType
                                           callRole:[TUICallingStatusManager shareInstance].callRole];
    }
}

- (void)showCallingView {
    if (self.alreadyShownCallKitView) {
        return;
    }
    self.alreadyShownCallKitView = YES;
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:self.containerView];
  [self.containerView addSubview:self.giftView];
  [self.containerView addSubview:self.rechargeView];
  self.giftView.mm_y = UIScreen.mainScreen.bounds.size.height;
  self.rechargeView.mm_y = UIScreen.mainScreen.bounds.size.height;
    TUICallingNavigationController *nvc = [[TUICallingNavigationController alloc] initWithRootViewController: viewController];
    [nvc setNavigationBarHidden:true];
    self.callingWindow.rootViewController = nvc;
    self.callingWindow.hidden = NO;
  self.callingWindow.alpha = self.isRandom ? 0 : 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_callingWindow != nil) {
            [self.callingWindow t_makeKeyAndVisible];
        }
    });
}

- (void)closeCallingView {
    [self clearAllSubViews];
  [self.userInfoView clean];
  self.tips.attributedText = nil;
  [self.incomeView updateIncome:nil];
  [self.costView removeFromSuperview];
  [self.userAvatarView removeFromSuperview];
    [self.containerView removeFromSuperview];
    self.callingWindow.hidden = YES;
    self.callingWindow = nil;
  self.isRandom = false;
    self.alreadyShownCallKitView = NO;
    [[TUICallingFloatingWindowManager shareInstance] closeMicroFloatingWindow:nil];
}

- (UIView *)getCallingView {
    return self.containerView;
}

- (void)updateCallingTimeStr:(NSString *)timeStr {
    [self.timerView updateTimerText:timeStr];
    [[TUICallingFloatingWindowManager shareInstance] updateDescribeText:timeStr];
}

- (void)userEnter:(CallingUserModel *)userModel {
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(userEnter:)]) {
        [self.backgroundView userEnter:userModel];
    }
}

- (void)userLeave:(CallingUserModel *)userModel {
    if (self.callingCalleeView) {
        [self.callingCalleeView userLeave:userModel];
    }
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(userLeave:)]) {
        [self.backgroundView userLeave:userModel];
    }
    
}

- (void)updateUser:(CallingUserModel *)userModel {
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateUserInfo:)]) {
        [self.backgroundView updateUserInfo:userModel];
    }
    if ([self.remoteUser.userId isEqualToString:userModel.userId]) {
        [[TUICallingFloatingWindowManager shareInstance] updateUserModel:userModel];
    }
}

- (void)enableFloatWindow:(BOOL)enable {
    self.enableFloatWindow = enable;
}
- (void)beginCall{
  if ([self.callingFunctionView respondsToSelector:@selector(updateBeginStatus)]){
    [self.callingFunctionView updateBeginStatus];
  }
  self.userInfoView.hidden = true;
  NSString *s = @"文撩提醒您：";
  NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
  style.lineSpacing = 5;
  NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n请勿在视频时发布涉黄涉政等违法行为，一经发现将自动封号，以色情、婚恋、线下约会或其他异常行为引诱添加第三方账号或多刷礼物等多为诈骗，请及时向平台举报!",s] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:UIColor.whiteColor,NSParagraphStyleAttributeName:style}];
  [att addAttributes:@{NSForegroundColorAttributeName:[UIColor t_colorWithHexString:@"#25E093"]} range:NSMakeRange(0, s.length)];
  self.tips.attributedText = att;
  
}
- (void)updateWindow{
  if (self.callingWindow.alpha == 0){
    [UIView animateWithDuration:0.5 animations:^{
      self.callingWindow.alpha = 1;
    }];
  }
}
#pragma mark - Action Event

- (void)floatingWindowTouchEvent:(UIButton *)sender {
    TUICallingVideoRenderView *renderView = nil;
    TUICallMediaType callMediaType = [TUICallingStatusManager shareInstance].callMediaType;
    TUICallScene callScene = [TUICallingStatusManager shareInstance].callScene;
    if (callScene == TUICallSceneSingle && callMediaType == TUICallMediaTypeVideo) {
        if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusAccept) {
            renderView = self.remotePreView;
        } else {
            renderView = self.localPreView;
        }
    }
    self.localPreView.delegate = [TUICallingFloatingWindowManager shareInstance].floatWindow;
    self.remotePreView.delegate = [TUICallingFloatingWindowManager shareInstance].floatWindow;
    [[TUICallingFloatingWindowManager shareInstance] showMicroFloatingWindow:^(BOOL finished) {
        [[TUICallingFloatingWindowManager shareInstance] setRenderView:renderView];
        if (finished && ([TUICallingStatusManager shareInstance].callMediaType == TUICallMediaTypeAudio || !renderView)) {
            [[TUICallingFloatingWindowManager shareInstance] updateDescribeText:@""];
        }
    }];
}

- (void)addOtherUserTouchEvent:(UIButton *)sender {
    NSDictionary *param = @{
        TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_GroupIDKey : [TUICallingStatusManager shareInstance].groupId ?: @"",
        TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_SelectedUserIDListKey : [TUICallingUserManager allUserIdList] ?: @[],
        TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_UserDataKey : TUICallKit_TUIGroupService_UserDataValue,
        TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod_NameKey : TUIKitLocalizableString(Make-a-call),
    };
    UIViewController *viewController = [TUICore callService:TUICore_TUIGroupService
                                                     method:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
                                                      param:param];
    if (!viewController) {
        viewController = [TUICore callService:TUICore_TUIGroupService_Minimalist
                                       method:TUICore_TUIGroupService_GetSelectGroupMemberViewControllerMethod
                                        param:param];
    }
    TUINavigationController *navigationController = [[TUINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.callingWindow.rootViewController presentViewController:navigationController animated:NO completion:nil];
}

#pragma mark - TUICallingStatusManagerProtocol

- (void)updateCallType {
    if (![TUICallingStatusManager shareInstance].callMediaType) {
        return;
    }
    
    [self clearAllSubViews];
    
    if ([TUICallingStatusManager shareInstance].callScene == TUICallSceneSingle) {
        if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusAccept) {
            [self initSingleAcceptCallView];
            [self initHandsFree:[TUICallingStatusManager shareInstance].audioPlaybackDevice];
            [self updateCallingUserView:@""];
        } else {
            [self initSingleWaitingView];
            [self updateCallingUserView];
        }
    } else {
        [self initGroupWaitingView];
        [self updateCallingUserView];
    }
    
    [self updateContainerViewBgColor];
    [self updateViewTextColor];
    [self initFloatingWindowBtn];
}

- (void)updateCallStatus {
    if ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusAccept) {
        TUICallingVideoRenderView *renderView = nil;
        
        if ([TUICallingStatusManager shareInstance].callScene == TUICallSceneSingle) {
            [self initSingleAcceptCallView];
            if ([TUICallingStatusManager shareInstance].callMediaType == TUICallMediaTypeVideo) {
                renderView = self.remotePreView;
            }
        } else {
            [self initGroupAcceptCallView];
        }
        
        [self updateCallingUserView:@""];
        [self updateCallingBackgroundView:self.remoteUser];
        [self updateContainerViewBgColor];
        [self updateViewTextColor];
        [self initFloatingWindowBtn];
        [[TUICallingFloatingWindowManager shareInstance] updateUserModel:self.remoteUser];
        [[TUICallingFloatingWindowManager shareInstance] setRenderView:renderView];
        
        if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateRemoteView)]) {
            [self.backgroundView updateRemoteView];
        }
    }
}

- (void)updateIsCloseCamera {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateCameraOpenStatus)]) {
        [self.callingFunctionView updateCameraOpenStatus];
    }
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateCameraOpenStatus:)]) {
        [self.backgroundView updateCameraOpenStatus:![TUICallingStatusManager shareInstance].isCloseCamera];
    }
}

- (void)updateMicMute {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateMicMuteStatus)]) {
        [self.callingFunctionView updateMicMuteStatus];
    }
}

- (void)updateAudioPlaybackDevice {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateHandsFreeStatus)]) {
        [self.callingFunctionView updateHandsFreeStatus];
    }
}

#pragma mark - TUICallingFloatingWindowManagerDelegate

- (void)floatingWindowDidClickView {
    self.localPreView.delegate = self.backgroundView;
    self.remotePreView.delegate = self.backgroundView;
    
    if (self.backgroundView && [self.backgroundView respondsToSelector:@selector(updateCallingSingleView)]) {
        [self.backgroundView updateCallingSingleView];
    }
}

- (void)closeFloatingWindow {
    [TUICallingAction hangup];
}

#pragma mark - TUINotificationProtocol

- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIGroupNotify] && [subKey isEqualToString:TUICore_TUIGroupNotify_SelectGroupMemberSubKey]) {
        NSString *userData = param[TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserDataKey];
        if (!(userData && [userData isKindOfClass:NSString.class] && [userData isEqualToString:TUICallKit_TUIGroupService_UserDataValue])) {
            return;
        }
        NSArray<TUIUserModel *> *selectUserList = param[TUICore_TUIGroupNotify_SelectGroupMemberSubKey_UserListKey];
        if (!(selectUserList && [selectUserList isKindOfClass:NSArray.class] && selectUserList.count > 0)) {
            return;
        }
        [TUICallingAction inviteUser:selectUserList succ:^(NSArray * _Nonnull userIDs) {
            __weak typeof(self) weakSelf = self;
            [[V2TIMManager sharedInstance] getUsersInfo:userIDs succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                __strong typeof(self) strongSelf = weakSelf;
                for (V2TIMUserFullInfo *userInfo in infoList) {
                    CallingUserModel *userModel = [TUICallingCommon covertUser:userInfo];
                    [TUICallingUserManager cacheUser:userModel];
                    if (strongSelf.backgroundView && [strongSelf.backgroundView respondsToSelector:@selector(userAdd:)]) {
                        [strongSelf.backgroundView userAdd:userModel];
                    }
                }
            } fail:nil];
        } fail:^(int code, NSString * _Nonnull desc) {
            [[TUICallingCommon getKeyWindow] makeToast:desc];
        }];
    }
}

#pragma mark - Private Method

- (void)updateContainerViewBgColor {
    TUICallMediaType callMediaType = [TUICallingStatusManager shareInstance].callMediaType;
    TUICallScene callScene = [TUICallingStatusManager shareInstance].callScene;
    UIColor *backgroundColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
    if ((callScene != TUICallSceneSingle) || (callMediaType == TUICallMediaTypeVideo)) {
        backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
    }
  self.containerView.backgroundColor = UIColor.blackColor;//backgroundColor;
}

- (void)updateViewTextColor {
    TUICallMediaType callMediaType = [TUICallingStatusManager shareInstance].callMediaType;
    TUICallScene callScene = [TUICallingStatusManager shareInstance].callScene;
    UIColor *textColor = [UIColor t_colorWithHexString:@"#000000"];
    if ((callScene != TUICallSceneSingle) || (callMediaType == TUICallMediaTypeVideo)) {
        textColor = [UIColor t_colorWithHexString:@"#F2F2F2"];
    }
    [self.timerView setTimerTextColor:textColor];
    [self updateFunctionViewTextColor:textColor];
    [self updateUserViewTextColor:textColor];
}

- (void)updateFunctionViewTextColor:(UIColor *)textColor {
    if (self.callingFunctionView && [self.callingFunctionView respondsToSelector:@selector(updateTextColor:)]) {
        [self.callingFunctionView updateTextColor:textColor];
    }
}

- (void)updateUserViewTextColor:(UIColor *)textColor {
    if (self.callingUserView && [self.callingUserView respondsToSelector:@selector(updateTextColor:)]) {
        [self.callingUserView updateTextColor:textColor];
    }
}

- (NSString *)getWaitingText {
    NSString *waitingText = @"";
    switch ([TUICallingStatusManager shareInstance].callMediaType) {
        case TUICallMediaTypeAudio:{
            if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
                waitingText = TUICallingLocalize(@"Demo.TRTC.Calling.waitaccept");
            } else {
                waitingText = TUICallingLocalize(@"Demo.TRTC.calling.invitetoaudiocall");
            }
        } break;
        case TUICallMediaTypeVideo:{
            if ([TUICallingStatusManager shareInstance].callRole == TUICallRoleCall) {
                waitingText = TUICallingLocalize(@"Demo.TRTC.Calling.waitaccept");
            } else {
                waitingText = TUICallingLocalize(@"Demo.TRTC.calling.invitetovideocall");
            }
        } break;
        case TUICallMediaTypeUnknown:
        default:
            break;
    }
    return waitingText;
}

#pragma mark - Lazy

- (TUICallingTimerView *)timerView {
    if (!_timerView) {
        _timerView = [[TUICallingTimerView alloc] initWithFrame:CGRectZero];
    }
    return _timerView;
}

- (TUICallingSwitchToAudioView *)switchToAudioView {
    if (!_switchToAudioView) {
        _switchToAudioView = [[TUICallingSwitchToAudioView alloc] initWithFrame:CGRectZero];
    }
    return _switchToAudioView;
}

- (TUICallingCalleeView *)callingCalleeView {
    if (!_callingCalleeView) {
        _callingCalleeView = [[TUICallingCalleeView alloc] initWithFrame:CGRectZero];
        _callingCalleeView.backgroundColor = [UIColor clearColor];
    }
    return _callingCalleeView;
}

- (UIWindow *)callingWindow {
    if (!_callingWindow) {
        _callingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _callingWindow.windowLevel = UIWindowLevelAlert - 1;
        _callingWindow.backgroundColor = [UIColor clearColor];
    }
    return _callingWindow;
}

- (TUICallingVideoRenderView *)localPreView {
    if (!_localPreView) {
        _localPreView = [[TUICallingVideoRenderView alloc] initWithFrame:CGRectZero];
        _localPreView.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
      _localPreView.layer.cornerRadius = 10;
      _localPreView.layer.borderWidth = 1.5;
      _localPreView.layer.borderColor = UIColor.whiteColor.CGColor;
      _localPreView.clipsToBounds = true;
        _localPreView.delegate = self.backgroundView;
    }
    return _localPreView;
}

- (TUICallingVideoRenderView *)remotePreView {
    if (!_remotePreView) {
        _remotePreView = [[TUICallingVideoRenderView alloc] initWithFrame:CGRectZero];
        _remotePreView.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
        _remotePreView.delegate = self.backgroundView;
    }
    return _remotePreView;
}

- (UIButton *)floatingWindowBtn {
    if (!_floatingWindowBtn) {
        _floatingWindowBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_floatingWindowBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:@"ic_min_window_white"]
                                      forState:UIControlStateNormal];
        [_floatingWindowBtn addTarget:self action:@selector(floatingWindowTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _floatingWindowBtn;
}

- (UIButton *)addOtherUserBtn {
    if (!_addOtherUserBtn) {
        _addOtherUserBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_addOtherUserBtn setBackgroundImage:[TUICallingCommon getBundleImageWithName:@"ic_add_user"] forState:UIControlStateNormal];
        [_addOtherUserBtn addTarget:self action:@selector(addOtherUserTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addOtherUserBtn;
}
- (CustomUserInfoView *)userInfoView{
  if (!_userInfoView){
    _userInfoView = [CustomUserInfoView new];
    _userInfoView.backgroundColor = UIColor.redColor;
    _userInfoView.hidden = true;
  }
  return _userInfoView;
}
- (CustomGiftView *)giftView{
  if (!_giftView){
    _giftView = [CustomGiftView new];
    _giftView.manager = self;
  }
  return _giftView;
}
- (CustomRechargeView *)rechargeView{
  if (!_rechargeView){
    _rechargeView = [CustomRechargeView new];
  }
  return _rechargeView;
}
- (CustomMinuteCostView *)costView{
  if (!_costView){
    _costView = [CustomMinuteCostView new];
  }
  return _costView;
}
- (CustomIncomeView *)incomeView{
  if (!_incomeView){
    _incomeView = [CustomIncomeView new];
  }
  return _incomeView;
}
- (UIImageView *)userAvatarView{
  if (!_userAvatarView){
    _userAvatarView = [UIImageView new];
    _userAvatarView.contentMode = UIViewContentModeScaleAspectFill;
    _userAvatarView.clipsToBounds = true;
  }
  return _userAvatarView;
}
- (UILabel *)tips{
  if (!_tips){
    _tips = [UILabel new];
    _tips.numberOfLines = 0;
  }
  return _tips;
}

@end
