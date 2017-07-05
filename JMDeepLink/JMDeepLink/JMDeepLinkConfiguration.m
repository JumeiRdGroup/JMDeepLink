//
//  JMDeepLinkConfiguration.m
//  JuMei
//
//  Created by bojiaz on 2017/5/5.
//  Copyright © 2017年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkConfiguration.h"
#import "JMDeepLinkStatistics.h"
#import "JMDeepLink+Additionals.h"

@interface JMDeepLinkConfiguration()

@end

@implementation JMDeepLinkConfiguration

+ (JMDeepLinkConfiguration *)defaultConfiguration {
    static JMDeepLinkConfiguration *configuration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configuration = [[JMDeepLinkConfiguration alloc] init];
        configuration.needGetUrlWhenLaunch = YES;
        configuration.jumpUrlKey = @"jumeimallUrl";
        configuration.defaultPageUrl = @"http://newjump.jumei.com/jumeiApp";
        configuration.goToSafariLabel = @"jumei.com";
    });
    return configuration;
}

- (void)setDeeplinkHosts:(NSArray *)deeplinkHosts {
    if (![deeplinkHosts isKindOfClass:[NSArray class]]) {
        return ;
    }
    
    _deeplinkHosts = deeplinkHosts;
    [JMDeepLinkStatistics getInstance].deeplinkHosts = deeplinkHosts;
}

- (void)setRequestDynamicParams:(NSDictionary *)requestDynamicParams {
    if (!requestDynamicParams) {
        _requestDynamicParams = nil;
        [JMDeepLinkStatistics getInstance].dyParams = nil;
    }
    
    if (![requestDynamicParams isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _requestDynamicParams = requestDynamicParams;
    [JMDeepLinkStatistics getInstance].dyParams = requestDynamicParams;
}

- (void)setRequestDynamicCookies:(NSDictionary *)requestDynamicCookies {
    if (!requestDynamicCookies) {
        _requestDynamicCookies = nil;
        [JMDeepLinkStatistics getInstance].dyCookies = nil;
    }
    
    if (![requestDynamicCookies isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    _requestDynamicCookies = requestDynamicCookies;
    [JMDeepLinkStatistics getInstance].dyCookies = requestDynamicCookies;
}

- (void)setJumpUrlKey:(NSString *)jumpUrlKey {
    if ([NSString isNilOrNSNullOrEmptyOrWhitespace:jumpUrlKey]) {
        return;
    }
    [JMDeepLinkStatistics getInstance].jumpUrlKey = jumpUrlKey;
    _jumpUrlKey = jumpUrlKey;
}

- (void)setDefaultPageUrl:(NSString *)defaultPageUrl {
    if ([NSString isNilOrNSNullOrEmptyOrWhitespace:defaultPageUrl]) {
        return;
    }
    [JMDeepLinkStatistics getInstance].defaultPageUrl = defaultPageUrl;
    _defaultPageUrl = defaultPageUrl;
}

- (void)setGoToSafariLabel:(NSString *)goToSafariLabel {
    if ([NSString isNilOrNSNullOrEmptyOrWhitespace:goToSafariLabel]) {
        return;
    }
    [JMDeepLinkStatistics getInstance].goToSafariLabel = goToSafariLabel;
    _goToSafariLabel = goToSafariLabel;
}

@end
