//
//  MTWebViewController+MTNavigationBarSetting.m
//  MTWebKitComponent
//
//  Created by Tom.Liu on 2021/3/16.
//

#import "MTWebViewController+YKNavigationBarSetting.h"

@implementation MTWebViewController (YKNavigationBarSetting)

- (void)yk_setNormalTitle:(NSString *)title withFont:(UIFont*)font {
    [self yk_setTitle:title color:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] font:font];
}

- (void)yk_setWhiteTitle:(NSString *)title withFont:(UIFont*)font {
    [self yk_setTitle:title color:[UIColor whiteColor] font:font];
}

- (void)yk_setTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font
{
    if (!self.navigationController) return;
    title = title ? title : @"";
    color = color ? color : [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] ;
    font = font ? font : [UIFont systemFontOfSize:18.0];
    CGSize size = CGSizeMake(0, 24);
    NSDictionary *attributeTmp = @{NSFontAttributeName: font};
    CGRect frame = [title boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeTmp context:nil];
    CGFloat width = frame.size.width;
    if (width > [UIScreen mainScreen].bounds.size.width - 150) {
//        文案太长
        NSInteger length = title.length *([UIScreen mainScreen].bounds.size.width - 150)/width;
        length -= 2;
        length = length/2;
        title = [NSString stringWithFormat:@"%@...%@",[title substringToIndex:length],[title substringFromIndex:(title.length-length)]];
    }
    self.navigationItem.title = title;
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attribute];
}


@end
