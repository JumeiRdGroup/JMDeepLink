//
//  JMDeepLink.m
//  JuMei
//
//  Created by bojiaz on 16/9/12.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLink.h"
#import "JMDeepLinkMatchHelper.h"
#import "JMDeepLinkObserver.h"
#import "JMDeepLinkRequestQueue.h"
#import "JMDeepLinkOpenRequest.h"
#import "JMDeepLinkHttpClient.h"
#import "JMDeepLinkStatistics.h"
#import "JMDeepLinkRequestQueue.h"
#import "JMDeepLinkBlocks.h"
#import "JMDeepLinkHelper.h"
#import "JMDeepLink+Additionals.h"
#import "UIControl+Deeplink.h"
#import "JMDeepLinkConfiguration.h"

@interface JMDeepLink()

@property (nonatomic, assign) BOOL isInitialized;

@property (nonatomic, strong) JMDeepLinkStatistics *statistics;

@property (nonatomic, strong) JMDeepLinkRequestQueue *requestQueue;

@property (nonatomic, strong) JMDeepLinkConfiguration *configuration;

@end

@implementation JMDeepLink

+ (JMDeepLink *)getInstance {
    static JMDeepLink *deeplink;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [UIControl deeplinkMethodExchange];
        
        JMDeepLinkStatistics *statistics = [JMDeepLinkStatistics getInstance];
        
        deeplink = [[JMDeepLink alloc] initWithStatistics:statistics];
        
        deeplink.requestQueue = [JMDeepLinkRequestQueue getInstance];
        
        [deeplink.requestQueue clearQueue];
        
    });
    
    return deeplink;
}

- (instancetype)initWithStatistics:(JMDeepLinkStatistics *)statistics {

    self = [super init];
    
    if (self) {
        _statistics = statistics;
        _isInitialized = NO;
    }
    return self;
}

- (void)initWithAppID:(NSString *)appId withLaunchOptions:(NSDictionary *)options  Configuration:(JMDeepLinkConfiguration *)config {
    
    if ([JMDeepLinkObserver getOSVersion].integerValue < 8) {
        return;
    }
    
    self.configuration = config;
    
    self.statistics.appID = appId;
    
    if (![options objectForKey:UIApplicationLaunchOptionsURLKey] && ![options objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey]) {
        
        if (self.configuration.needGetUrlWhenLaunch) {
            [self initUserSessionAndCallCallback:YES];
        }
    }
//    else if ([options objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey]) {
//        
//        id activity = [[options objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey] objectForKey:@"UIApplicationLaunchOptionsUserActivityKey"];
//        if (activity && [activity isKindOfClass:[NSUserActivity class]]) {
//            [self handleUserActivity:activity];
//            return;
//        }JMDeepLink
//    }
}

- (BOOL)continueUserActivity:(NSUserActivity *)userActivity {

    return [self handleUserActivity:userActivity];
}

- (BOOL)handleUserActivity:(NSUserActivity *)userActivity {

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        
        if ([JMDeepLinkHelper isDeepLinkJumpStr:[userActivity.webpageURL absoluteString]]) {
            NSDictionary *dic = [self getParamsDicFromUrl:userActivity.webpageURL];
            NSString *jumeiUrl = [dic objectForKey:[JMDeepLinkStatistics getInstance].jumpUrlKey];
            if (![NSString isNilOrNSNullOrEmptyOrWhitespace:jumeiUrl]) {
                [JMDeepLinkStatistics getInstance].jumpUrl = jumeiUrl;
            } else {
                [JMDeepLinkStatistics getInstance].jumpUrl = nil;
            }
            [self initUserSessionAndCallCallback:YES];
            if (self.configuration.delegate && [self.configuration.delegate respondsToSelector:@selector(deeplinkDataReturned:withError:)]) {
                [self.configuration.delegate deeplinkDataReturned:dic withError:nil];
            }
            return YES;
        }
        return NO;
    }
    
    return NO;
}

- (NSDictionary *)getParamsDicFromUrl:(NSURL *)url {

    if (!url) {
        return nil;
    }
    
    NSMutableDictionary *dic = [@{} mutableCopy];
    
    NSString *urlStr = [url absoluteString];
    
    NSString *jumeimaillStr = [JMDeepLinkHelper getStringFromUrl:urlStr needle:[NSString stringWithFormat:@"%@=",[JMDeepLinkStatistics getInstance].jumpUrlKey]];
    
    if ([NSString isNilOrNSNullOrEmptyOrWhitespace:jumeimaillStr]) {
        return [dic copy];
    }
    
    [dic dlSetSafeObject:jumeimaillStr forKey:[JMDeepLinkStatistics getInstance].jumpUrlKey];
    
    return [dic copy];
}

- (void)initUserSessionAndCallCallback:(BOOL)callCallback {

    [self initializeDeepLink];
}

- (void)initializeDeepLink {
    
    if ([JMDeepLinkObserver getOSVersion].integerValue >= 9) {

        [self registerInstallOrOpen];
    }
}

- (void)registerInstallOrOpen {
    
    JMDeepLinkOpenRequest *request = [[JMDeepLinkOpenRequest alloc] initWithSuccess:^(id response, NSURLSessionDataTask *dataTask) {
        NSDictionary *dic = self.statistics.userData;
        if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        
        if (self.configuration.delegate && [self.configuration.delegate respondsToSelector:@selector(deeplinkDataReturned:withError:)]) {
            [self.configuration.delegate deeplinkDataReturned:dic withError:nil];
        }
    } Fail:^(NSError *error, NSURLSessionDataTask *dataTask) {
        if (self.configuration.delegate && [self.configuration.delegate respondsToSelector:@selector(deeplinkDataReturned:withError:)]) {
            [self.configuration.delegate deeplinkDataReturned:nil withError:error];
        }
    }];
    
    [[JMDeepLinkRequestQueue getInstance] enquque:request];
    
    [[JMDeepLinkHttpClient getInstance] processRequest];
}


@end
