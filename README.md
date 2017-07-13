# JMDeepLink
deeplink，深度链接跳转，即直接在手机浏览器（包括QQ、微信内部浏览器）上点击跳转链接，则能直接唤起已安装app，且能跳转到对应页面的一项技术。

Apple在iOS9上引入了Universal Links，此为深度链接跳转实现的基础，相关官方文档为：[Support Universal Links](https://developer.apple.com/library/content/documentation/General/Conceptual/AppSearch/UniversalLinks.html#//apple_ref/doc/uid/TP40016308-CH12-SW1)

JMDeepLink 则是一个用于聚美优品内部的集成了深度链接跳转技术的SDK。

## 安装

* download 项目，然后复制 JMDeepLink.framework 到项目即可
* 或者在已安装的 cocoapods 中，podfile 里添加"JMDeepLink"，然后pod install即可

## 使用

### sdk布署

在 Appdelegate 内, didFinishLaunchingWithOptions 中添加：

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    JMDeepLinkConfiguration *config = [JMDeepLinkConfiguration defaultConfiguration];
    
    config.delegate = self;
    
    [[JMDeepLink getInstance] initWithAppID:nil withLaunchOptions:launchOptions Configuration:config];
    
    return YES;
}
```
添加 continueUserActivity 回调

```
- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *))restorationHandler {
      
        return [[JMDeepLink getInstance] continueUserActivity:userActivity];
}
```

添加 JMDeepLinkDelegate 的回调 deeplinkDataReturned，params中jumeimallUrl 则为对应的内部url跳转：

```
- (void)deeplinkDataReturned: (NSDictionary *) params withError: (NSError *) error {
	NSString *url = [params objectForKey:@"jumeimallUrl"];
}
```

### 环境布署
1. app设置

	开启app项目相应target中Capabilities内 **Associated Domains** 一项，并以 **applinks:www.myhost.com** 的格式设置支持跳转的domain。

2. web布署

	* 创建一个 **apple-app-site-association** 文件，格式如下。appID 为 teamID 和 Bundle Identifier 组合，其中 teamID 可在对应开发者账号中查询；paths 则对应了可跳转的 url，若为*则表示该路径下所有 path 均可跳转
	
	* 将 **apple-app-site-association** 传至跳转 domian 对应的 https web server 的 **root** 目录
	
	* Universal Links的跳转利用了handoff的机制，在跳转的时候将**链接及相关信息**封装在了 **didFinishLaunchingWithOptions 中的 launchOptions 内**或是**continueUserActivity中的NSUserActivity内**。JMDeepLink SDK的跳转链接格式为https://www.myhost.com?jumeimallUrl=xxx，其中jumeimallUrl为带给app内部root跳转的参数。
	

```
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "teamID.com.jumei.test",
                "paths": [ "/home/news/", "/videos/*"]
            },
            {
                "appID": "teamID.com.jemei.testOne",
                "paths": [ "*" ]
            }
        ]
    }
}
```
	

## 说明

### Deferred Deep Linking

**deferred deep linking** 是指用户打开一个 web page 的时候并没有安装对应的 app，希望用户在安装 app 以后可以 deep link 到对应内容。即下载app后第一次手动打开，app内部仍然可以跳转到对应的jumeimall链接。目前 JMDeepLink 的 **Deferred Deep Linking** 跳转使用了两个方案：

* safari 的 cookie 互通方案
* 模糊匹配方案

1. safari cookie
	
	iOS9以后，apple推出了 SFSafariViewController 这个类。SFSafariViewController 和 Safari 是共享一个沙盒，它们的 cookie 是互通的，JMDeepLink则是按照如下步骤来获得jumeimall链接：

	* 用户通过Safari浏览 web page且产生了行为，web将用户行为及者数据（如jumeimall）写入cookie
	* 引导用户下载app
	* 用户第一次打开app，app内打开一个透明的SFSafariViewController
	* app本地生成一个UUID（如，idfa）, 并通过这个隐藏的SFSafariViewController将UUID和cookie一通回传给server
	* server则可以通过这次带UUID的请求跟之前的session对应起来，然后查询更多的信息（包括jumeimall）返回给app
	* app拿到数据后销毁SFSafariViewController拿到jumaimall等信息后实现界面还原

	流程看起来较为复杂，且这种 deferred deep linking 只能在Safari中实现，在QQ内部浏览器或微信内部浏览器是不能实现的

2. 模糊匹配

	如上所说，在QQ或者微信内部浏览器打开，则无法实现cookie互通，即不能采用Safari方案实现 deferred deep linking。另一种 defferd deep linking 方案流程如下：
	
	* 用户在QQ或者微信浏览器上浏览 web page 且产生了行为
	* web 网页收集一些**唯一标识**设备信息，如ip，屏幕宽高，时间戳，iOS系统版本等，并传给server
	* app在下载完后，第一次打开时，app收集相同**唯一标识**设备信息，将传给server
	* 服务器经过对比，发现app传来的设备信息和web网页发来的设备信息相同，
	* 匹配成功，服务器则将跳转链接及相关信息（如jumeimall）等传给app，app在实现界面还原
	
	从上面的流程可以看得出，匹配成功的关键在于这个**唯一标识**设备信息。上面给出的筛选信息有ip，屏幕宽高，时间戳，iOS系统版本等。经过上面因素的筛选，且 deferred deep linking 只发生在app安装这种条件下，还是能较大概率实现匹配。
	
	既然是模糊匹配，那它存在什么弊端呢？？从上面的流程可以看出，这种方案可能有server会匹配失误而将错误的信息下发给app，app实现不应有的跳转。
	典型的情况是，两次模糊匹配时，如为同一型号的iphone(= =!iphone型号来来回回就这么几种)、同一系统版本，同一时间，在同一个WIFI下，则server是无法正确匹配的。同一WIFI下，服务端拿到的是外网ip是一样的，因此此时server无法正确匹配（加上端口号也是没用的= =）。最后期望的方法是能够在发送请求的时候尝试将内网ip作为参数传给server，但web中获取内网ip是较难，目前没有更好的方案。
	
	
##### Deferred Deep Linking 的未来制定方案

后面的版本中，我们将优化 Deferred Deep Linking 的方案。

该方案只能在iOS10上实现，因为iOS10上系统给js开发了API可以操作剪贴板，因此可以很容易在第三方APP内部的webview中将数据导入剪切板，然后在本app中获得数据。这种方案在实用性和准确率上都优于上面两种方案。


### Shutdown Deep Linking

Universal Link的跳转是iOS系统内部实现的功能。**在Universal Link跳转到app后，点击statusbar右上角的返回按钮，则会打开Safari，且使Universal Link跳转失效！！！！！！！！！**

重启Universal Link跳转的方法是：**在Safari打开的中间页下滑，点击浮动在上方view中的“打开按钮”**

这个机制使得Universal Link的跳转变得极不友好，因为普通用户在不留意的时候可能会点击右上角按钮，因此则使得Universal Link失效。这样，在下次 web page 中跳转的时候，则不会跳转。如果用户不在Safari中打开中间面，点击浮动在上方view中的“打开按钮”。那Universal Link 会一直失效！！！

JMDeepLink在此处的解决方案是**通过hook改变statusbar右上角的返回按钮的功能，使其永远无法关闭Universal Link， 转而跳往我们默认设置的页面**，hook代码如下：

```
@implementation UIControl(Deeplink)

+ (void)deeplinkMethodExchange {

    method_exchangeImplementations(class_getInstanceMethod(self, @selector(sendAction:to:forEvent:)),
                                   class_getInstanceMethod(self, @selector(directSendAction:to:forEvent:)));
}

- (void)directSendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event {

    NSLog(@"DeepLink Hook : action:%s, target:%@ forEvent:%@",sel_getName(action),target,event);
    //左上角为UIStatusBarBreadcrumbItemView 右上角为UIStatusBarOpenInSafariItemView
    if ([target isKindOfClass:NSClassFromString(@"UIStatusBarOpenInSafariItemView")]) {
        NSString *string = [target valueForKey:@"destinationText"];
        if ([string isEqualToString:[JMDeepLinkStatistics getInstance].goToSafariLabel]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[JMDeepLinkStatistics getInstance].defaultPageUrl]];
        }
        return;
    }
    
    [self directSendAction:action to:target forEvent:event];
}


@end

```







