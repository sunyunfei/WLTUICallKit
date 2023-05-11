//
//  CustomUserInfoView.h
//  TUICallKit
//
//  Created by Yuj on 2023/4/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomUserInfoView : UIView
- (void)clean;
- (void)updateTips:(NSString *)tip;
- (void)updateInfo:(nullable NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
