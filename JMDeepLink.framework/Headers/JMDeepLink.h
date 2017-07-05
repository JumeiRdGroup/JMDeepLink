//
//  JMDeepLink.h
//  JuMei
//
//  Created by bojiaz on 16/9/12.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMDeepLinkConfiguration.h"

@interface JMDeepLink : NSObject

+ (JMDeepLink *)getInstance;

/** 初始化API，同时设置相应的委托对象
 * @param appId APP注册时生成的APP ID.
 * @param options launchOptions AppDelegate的didFinishLaunchingWithOptions方法所传回的参数
 * @param config 全局配置JMDeepLinkConfiguration，不能为空
 */

- (void)initWithAppID:(NSString *)appId withLaunchOptions:(NSDictionary *)options Configuration:(JMDeepLinkConfiguration *)config;

/** 让Deeplink通过NSUserActivity进行页面转换，成功则返回true，否则返回false，在application:continueUserActivity:restorationHandler中调用
 * @param userActivity userActivity存储了页面跳转的信息，包括来源与目的页面
 */
- (BOOL)continueUserActivity:(NSUserActivity *)userActivity;

@end
