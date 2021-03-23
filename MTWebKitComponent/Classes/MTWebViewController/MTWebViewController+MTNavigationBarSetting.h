//
//  MTWebViewController+MTNavigationBarSetting.h
//  MTWebKitComponent
//
//  Created by Tom.Liu on 2021/3/16.
//

#import "MTWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTWebViewController (MTNavigationBarSetting)
- (void)yk_setNormalTitle:(NSString *)title withFont:(UIFont*)font;
- (void)yk_setWhiteTitle:(NSString *)title withFont:(UIFont*)font ;
- (void)yk_setTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
