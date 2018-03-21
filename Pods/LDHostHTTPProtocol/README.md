# LDHostHTTPProtocol

LDHostHTTPProtocol继承自NSURLProtocol，为url链接提供host配置

## 使用方法

* app启动后调用[LDHostHTTPProtocol start]方法
* 调用+ (void)setHostMaps:(NSDictionary *)newHostMaps来设置host

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    ...
    #if TEST_VERSION
    [LDHostHTTPProtocol setHostMaps:[LocalSettings settings].hostMaps];
    [LDHostHTTPProtocol start];
    #endif
...
}
```

## 注意事项

当应用使用了多个NSURLProtocol的时候，生效的顺序与注册到app中的顺序相反，当网络请求发生时会首先使用最后注册的NSURLProtocol，判断+ (BOOL)canInitWithRequest:(NSURLRequest *)request能否handle此次请求，无法处理时继续向前一个NSURLProtocol询问，若均无法处理则使用系统默认行为处理。
因此LDHostHTTPProtocol需要最晚注册到app来保证生效，目前ios的统计库MobileAnalysis使用了NSURLProtocol技术来统接口性能。