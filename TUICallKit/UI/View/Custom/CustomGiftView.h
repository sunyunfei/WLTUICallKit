//
//  CustomGiftView.h
//  TUICallKit
//
//  Created by Yuj on 2023/4/21.
//

#import <UIKit/UIKit.h>
#import "TUICallingViewManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface CustomGiftView : UIView
@property (nonatomic,weak) TUICallingViewManager *manager;
- (void)reloadData;
- (void)updateList:(NSArray *)data;
- (void)updateGold:(int)num;
@end

NS_ASSUME_NONNULL_END
