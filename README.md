# YKWebKitComponent

 组件简介
 
 
 <img src="http://ww1.sinaimg.cn/large/6de36fdcly1gop1cvpxkij20ku112dk2.jpg" alt="图片替换文本" width="400" align="bottom" />

 
使用WebViewJavascriptBridge完成原生和H5的交互，实现对WKWebvbiew的封装：
 
 - 导航栏实现关闭按钮和返回按钮
 - 监听webview页面返回事件完成返回按钮和关闭按钮的功能
 - 监听webview导航栏来改变原生导航栏的标题
 - 注册原生方法供给JS调用
 - 调用JS的方法，提供回调

WebViewJavascriptBridge介绍：

 [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)


## 使用方法

### 核心类 `YKWebViewController`

#### 初始化子类对象并加载URL
```ObjC

 - (instancetype)initWithUrl:(NSString *)url;
 
```

#### 主动调用JS方法

```
- (void)callJsFunctionWithModel:(YKWebBridgeHandlerModel*)model andCallBack:(YKWebbridgeHandlerDictionaryBlock)result;
```

#### 响应JS调用
实现`YKWebBridgeHandlerAction`的子类，并注册该类类名
```
+ (void)load {

    [YKWebBridgeActionCenter registerAction:[self class]];
}
```

重载以下方法即可

```
- (instancetype)initWithFunctionModel:(YKWebBridgeHandlerModel*)model {
    if (self = [super init]) {
        NSLog(@"model -- %@",[model mj_keyValues]);
    }
    return self;
}

- (void)processTheFunction {
    NSLog(@"调用扫码");
}

```



## 集成


```ruby
pod 'YKWebKitComponent'
```

## 前端 Vue - Demo使用

### Project setup
```
yarn install
```

### Compiles and hot-reloads for development
```
yarn serve
```