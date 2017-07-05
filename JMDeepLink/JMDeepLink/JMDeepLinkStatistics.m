//
//  JMDeepLinkStatistics.m
//  JuMei
//
//  Created by bojiaz on 16/9/18.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkStatistics.h"

NSString * const JMDEEPLINK_KEY_APPID = @"jm_deeplink_appID";

@interface JMDeepLinkStatistics()

@end

@implementation JMDeepLinkStatistics

@synthesize appID = _appID;
@synthesize userData = _userData;

+ (JMDeepLinkStatistics *)getInstance {
    static JMDeepLinkStatistics *statistics;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statistics = [[JMDeepLinkStatistics alloc] init];
    });
    
    return statistics;
}


- (void)setAppID:(NSString *)appID {

    if ([appID isKindOfClass:[NSString class]]) {
        _appID = appID;
    }
}

- (NSString *)appID {

    return [_appID lowercaseString];
}


- (void)setUserData:(NSDictionary *)userData {

    if ([userData isKindOfClass:[NSDictionary class]]) {
        _userData = userData;
    }
}

- (NSDictionary *)userData {

    return _userData;
}

@end
