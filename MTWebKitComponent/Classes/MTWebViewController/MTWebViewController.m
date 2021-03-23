//
//  MTWebViewController.m
//  MTWebKitComponent
//
//  Created by Tom.Liu on 2021/3/15.
//

#import "MTWebViewController.h"
#import <WebKit/WebKit.h>
#import <YKLayoutUtilityComponent/YKLayoutUtilityComponentHeader.h>

#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "MTWebBridgeHandlerModel.h"
#import "MTWebViewController+YKNavigationBarSetting.h"
#import "MTWebBridgeHandlerAction.h"






#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]
#define methodNotImplemented() mustOverride()



@interface MTWebViewController ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,strong) UIButton *closeBtn,*backBtn;
@property (nonatomic,strong) NSString *urlString;

@property (nonatomic,strong) WebViewJavascriptBridge* bridge;

@end

@implementation MTWebViewController



- (instancetype)initWithUrl:(NSString *)url {
    if(self==[super init]){
        _urlString =url;
    }
    return self;
}

- (WebViewJavascriptBridge *)bridge {
    if(!_bridge){
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    }
    return _bridge;
}


-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.to(self.view).left(0).right(0).top(self.viewTopMargin).bottom(0);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.webView);
        make.height.mas_equalTo(3);
    }];
}




- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    request.timeoutInterval = 15.0f;
    [self.webView loadRequest:request];
     
    NSString * title ;
    title= @"MTWebViewController";
    [self yk_setNormalTitle:title withFont:[UIFont systemFontOfSize:20 weight:100]];
    
    [self leftNavigationViews:@[self.backBtn,self.closeBtn]];
    [self registMethodSToJS];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:0];
    if (self.autoWebViewTitle) {
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:0];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    if (self.autoWebViewTitle) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
}


 

- (void)registMethodSToJS{

    [self.bridge registerHandler:kJsCallNativeMethodName  handler:^(id data, WVJBResponseCallback responseCallback) {
        MTWebBridgeHandlerModel * dataModel = [MTWebBridgeHandlerModel mj_objectWithKeyValues:data];
//        NSLog(@"\n --->Js调用native注册好的方法---%@： 传递参数: %@",dataModel.methodName , data);
        dispatch_async(webBridgeHandlerActionsQueue(), ^{
            webBridgeHandlerActionsLock();
//            NSLog(@"-------- 22 --- %@",[MTWebBridgeActionCenter handlerActions]);
            for (NSString *actionClassString in [MTWebBridgeActionCenter handlerActions]) {
                MTWebBridgeHandlerAction *action = [[NSClassFromString(actionClassString) alloc] initWithFunctionModel:dataModel];
                
                if (action) [action processTheFunction];
            }
            webBridgeHandlerActionsUnLock();
        });
        
        responseCallback(data);
        
    }];
 
}

- (void)callJsFunctionWithModel:(MTWebBridgeHandlerModel*)model andCallBack:(MTWebBridgeHandlerDictionaryBlock)result {
    
//    NSLog(@"\n --->native调用JS函数---%@ ",[model dataToPassTojS]);
        [self.bridge callHandler:kNativeCallJSMethodName data:[model dataToPassTojS] responseCallback:^(id responseData) {
            NSDictionary * dic = [responseData mj_keyValues];
            result(dic);
        }];


}

 

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
//    mustOverride();
}

- (void)back {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self close];
    }
//    mustOverride();
    
}



 
 
#pragma mark - 监听

/*
 *4.在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
         
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        [self yk_setNormalTitle:self.webView.title withFont:[UIFont systemFontOfSize:18]];
    }
}

- (void)navigationBarTapViewDidClicked:(UIButton*)button {
    
}

#pragma mark - WKWKNavigationDelegate Methods


/*
 *5.在WKWebViewd的代理中展示进度条，加载完成后隐藏进度条
 */

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    //加载完成后隐藏progressView
    //    self.progressView.hidden = YES;
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    //加载失败同样需要隐藏progressView
    self.progressView.hidden = YES;
}

//页面跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //允许页面跳转
    NSLog(@"%@",navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}

 
#pragma mark -- Properties
- (UIProgressView *)progressView {
    if(!_progressView){
        _progressView = [[UIProgressView alloc] init];
        _progressView.tintColor = [UIColor colorWithRed:0.11 green:0.50 blue:1.00 alpha:1.00];
        _progressView.backgroundColor = [UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00];
        //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
        
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

-(WKWebView *)webView {
    if(!_webView){
        
        WKWebViewConfiguration * wkconfig = [[WKWebViewConfiguration alloc] init];
        wkconfig.allowsInlineMediaPlayback = YES;
        wkconfig.allowsPictureInPictureMediaPlayback = YES;
        _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:wkconfig];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = UIButton.new;
        NSString * bundleNameWithExtension = @"MTWebViewController.bundle";
        NSString * bundlePath = [[NSBundle bundleForClass:[MTWebViewController class]].resourcePath
                                     stringByAppendingPathComponent:bundleNameWithExtension];
        NSBundle * bundle = [NSBundle bundleWithPath:bundlePath];
        UIImage * image = [UIImage imageNamed:@"x_back" inBundle:bundle compatibleWithTraitCollection:nil];
        [_closeBtn setImage:image forState:UIControlStateNormal];
        [_closeBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _closeBtn;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = UIButton.new ;
    
        NSString * bundleNameWithExtension = @"MTWebViewController.bundle";
        NSString * bundlePath = [[NSBundle bundleForClass:[MTWebViewController class]].resourcePath
                                     stringByAppendingPathComponent:bundleNameWithExtension];
        NSBundle * bundle = [NSBundle bundleWithPath:bundlePath];
        UIImage * image = [UIImage imageNamed:@"hp_nav_back_black" inBundle:bundle compatibleWithTraitCollection:nil];
//        [UIImage imageNamed:@"hp_nav_back_black"]
        [_backBtn setImage:image forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark -- Functions

- (CGFloat)viewTopMargin {
    if (self.navigationController.navigationBar.translucent == YES ||
        (self.navigationController.navigationBar.translucent == NO && self.extendedLayoutIncludesOpaqueBars == YES)) {

        return self.navigationController.navigationBar.frame.size.height + 20 + ([self devieIsAfterIPhoneX] ? 24 : 0);
    }
    return 0;
}

- (BOOL)devieIsAfterIPhoneX {
   BOOL iPhoneX = NO;
     if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
           return iPhoneX;
       }
       if (@available(iOS 11.0, *)) {
           UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
           if (mainWindow.safeAreaInsets.bottom > 0.0) {
               iPhoneX = YES;
           }
       }
       return iPhoneX;
    
}
- (void)leftNavigationViews:(NSArray<UIView *> *)views {
    [self addNavigationViews:views left:YES];
}

- (void)rightNavigationViews:(NSArray<UIView *> *)views {
    [self addNavigationViews:views left:NO];
}

- (void)addNavigationViews:(NSArray<UIView *> *)views left:(BOOL)isLeft {
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 0;

    NSMutableArray *array = [@[] mutableCopy];
    for (UIView *view in views) {
        UIView *tapView = [UIView new];
        [tapView addSubview:view];
        if (@available(ios 11.0, *)) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.to(tapView).left(isLeft ? 5 : 10).right(isLeft ? 10 : 5).top(10).bottom(10);
            }];
        }else {
            if ([view isKindOfClass:UIButton.class]) {
                CGFloat width = 0;
                UIButton *button = (UIButton *)view;
                if (button.titleLabel.text) {
                    width += [button.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
                }
                if (button.imageView.image) {
                    width += button.imageView.image.size.width;
                }
                tapView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, width, 44);
            }else {
                tapView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 44, 44);
            }
            view.frame = CGRectMake(0, 22-20/2, tapView.frame.size.width, 20);
        }
        UITapGestureRecognizer* tap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTapViewDidClicked:)];
        [tapView addGestureRecognizer:tap];

        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:tapView];
        [array addObject:item];
    }
    if (isLeft) {
        self.navigationItem.leftBarButtonItems = [array copy];
    }else {
        self.navigationItem.rightBarButtonItems = [array copy];
    }
}


@end
