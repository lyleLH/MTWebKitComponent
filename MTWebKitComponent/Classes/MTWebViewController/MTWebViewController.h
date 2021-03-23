//
//  MTWebViewController.h
//  MTWebKitComponent
//
//  Created by Tom.Liu on 2021/3/15.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^MTWebBridgeHandlerDictionaryBlock)(NSDictionary *dic);

@class  MTWebBridgeHandlerModel;

@interface MTWebViewController : UIViewController <WKNavigationDelegate,WKUIDelegate>


@property (nonatomic, strong) WKWebView *webView;
//是否监听webview的Title来设置导航栏标题
@property (nonatomic,assign) BOOL autoWebViewTitle;

- (instancetype)initWithUrl:(NSString *)url;

- (void)callJsFunctionWithModel:(MTWebBridgeHandlerModel*)model andCallBack:(MTWebBridgeHandlerDictionaryBlock)result;

@end

NS_ASSUME_NONNULL_END
