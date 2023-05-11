//
//  CustomButton.h
//  TUICallKit
//
//  Created by Yuj on 2023/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomButton : UIButton
- (instancetype)initWithImage:(NSString *)named title:(NSString *)title;
- (instancetype)initWithImage:(NSString *)named title:(NSString *)title color:(UIColor *)color;
- (void)updateImage:(UIImage *)image;
- (void)updateTitle:(NSString *)title;
- (void)updateFont:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
