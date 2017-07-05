//
//  JMDeepLinkBaseRequest.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkBaseRequest.h"
#import "JMDeepLinkObserver.h"
#import "JMDeepLinkStatistics.h"

#import "JMDeepLink+Additionals.h"
#import <UIKit/UIKit.h>

@interface JMDeepLinkBaseRequest()

@property (nonatomic, strong) NSDictionary *dyParams;

@property (nonatomic, strong) NSDictionary *dyCookies;

@end

@implementation JMDeepLinkBaseRequest

- (NSString *)baseUrl {

    return @"";
}

- (NSString *)url {

    return @"";
}

- (JMDeepLinkRequestMethod)method {
    
    return JMDeepLinkGetRequest;
}

- (NSDictionary *)baseParameters {
    NSMutableDictionary *dic = [@{} mutableCopy];
    
    [dic dlSetSafeObject:[JMDeepLinkObserver getPlatform] forKey:@"platform"];
    
    return [dic copy];
}

- (NSDictionary *)customParameters {
    return nil;
}

- (BOOL)addDynamicParams {
    NSDictionary *params = [JMDeepLinkStatistics getInstance].dyParams;
    if (!params || ![params isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    self.dyParams = params;
    return YES;
}

- (NSDictionary *)params {
    
    NSMutableDictionary *mParams = [NSMutableDictionary dictionary];
    
    NSDictionary *baseParams = [self baseParameters];
    for (NSString *key in baseParams) {
        if (!key || ![key isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *value = [baseParams objectForKey:key];
        if (!value || ![value isKindOfClass:[NSString class]]) {
            continue;
        }
        [mParams dlSetSafeObject:value forKey:key];
    }
    
    NSDictionary *customParams = [self customParameters];
    for (NSString *key in customParams) {
        if (!key || ![key isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *value = [customParams objectForKey:key];
        if (!value || ![value isKindOfClass:[NSString class]]) {
            continue;
        }
        [mParams dlSetSafeObject:value forKey:key];
    }
    
    if ([self addDynamicParams]) {
        for (NSString *key in self.dyParams) {
            if (!key || ![key isKindOfClass:[NSString class]]) {
                continue;
            }
            NSString *value = [self.dyParams objectForKey:key];
            if (!value || ![value isKindOfClass:[NSString class]]) {
                continue;
            }
            [mParams dlSetSafeObject:value forKey:key];
        }
    }
    
    return [mParams copy];
}

- (NSDictionary *)baseHeaders {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    NSString *cookie = [self cookie];
    [headers dlSetSafeObject:cookie forKey:@"Cookie"];
    
    return headers;
}

- (NSDictionary *)customHeaders {
    return nil;
}

- (NSDictionary *)requestHeaders {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    NSDictionary *baseHeaders = [self baseHeaders];
    for (NSString *key in baseHeaders) {
        [headers dlSetSafeObject:[baseHeaders objectForKey:key] forKey:key];
    }
    
    NSDictionary *customHeaders = [self customHeaders];
    for (NSString *key in customHeaders) {
        [headers dlSetSafeObject:[customHeaders objectForKey:key] forKey:key];
    }
    
    return [headers copy];
}

- (NSString *)baseCookie
{
    NSMutableString *cookieString_ = [NSMutableString string];
    UIDevice *device_ = [UIDevice currentDevice];

    //添加idfa
    BOOL isRealHardwareId;
    NSString *hardwareIdType;
    NSString *hardwareId = [JMDeepLinkObserver getUniqueHardwareId:&isRealHardwareId isDebug:NO andType:&hardwareIdType];
    if (hardwareId && isRealHardwareId) {
        [cookieString_ appendFormat:@"idfa=%@; ", hardwareId];
    }
    
    //添加idfv
    if ([device_ respondsToSelector:@selector(identifierForVendor)]) {
        NSUUID *idfv_ = [device_ identifierForVendor];
        NSString *uufvString_ = [idfv_ UUIDString];
        if (uufvString_) {
            [cookieString_ appendFormat:@"idfv=%@; ", [uufvString_ lowercaseString]];
        }
    }
    
    //添加appid
    if ([JMDeepLinkObserver getAppID]) {
        [cookieString_ appendFormat:@"appid=%@; ", [JMDeepLinkObserver getAppID]];
    }
    
    //添加appsecret
    if ([JMDeepLinkObserver readAppsecret]) {
        [cookieString_ appendFormat:@"appsecret=%@; ", [JMDeepLinkObserver readAppsecret]];//
    }
    
    return [NSString stringWithString:cookieString_];
}

- (NSString *)customCookie {
    return nil;
}

- (BOOL)addDynamicCookies {
    NSDictionary *dyCookies = [JMDeepLinkStatistics getInstance].dyCookies;
    if (!dyCookies || ![dyCookies isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    self.dyCookies = dyCookies;
    return YES;
}

- (NSString *)cookie {
    NSMutableString *cookieStr = [NSMutableString string];
    
    NSString *baseCookie = [self baseCookie];
    if (baseCookie && [baseCookie isKindOfClass:[NSString class]]) {
        [cookieStr appendString:baseCookie];
    }
    
    NSString *customCookie = [self customCookie];
    if (customCookie && [customCookie isKindOfClass:[NSString class]]) {
        [cookieStr appendString:customCookie];
    }
    
    if ([self addDynamicCookies]) {
        for (NSString *key in self.dyCookies) {
            if (!key || ![key isKindOfClass:[NSString class]]) {
                continue;
            }
            NSString *value = [self.dyCookies objectForKey:key];
            if (!value || ![value isKindOfClass:[NSString class]]) {
                continue;
            }
            [cookieStr appendFormat:@"%@=%@; ",key,value];
        }
    }
    
    return [NSString stringWithString:cookieStr];
}

- (void)processWithResponse:(JMDeepLinkResponse *)response dataTask:(NSURLSessionDataTask *)task {
    [self doesNotRecognizeSelector:_cmd];
    return;
}

- (void)processWithError:(NSError *)error dataTask:(NSURLSessionDataTask *)task {
    [self doesNotRecognizeSelector:_cmd];
    return;
}


-(void)buildCookiesWithTask:(NSURLSessionDataTask *)task
{
//    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//    NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields]
//                                                              forURL:[response URL]];
//    for (NSHTTPCookie *cookie in cookies) {
//        NSMutableDictionary * cookieProperties = [[cookie properties] mutableCopy];
//        [cookieProperties setObject:MASMobAppServerBaseURLString forKey:NSHTTPCookieDomain];
//        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//        
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
//    }
    
}

@end
