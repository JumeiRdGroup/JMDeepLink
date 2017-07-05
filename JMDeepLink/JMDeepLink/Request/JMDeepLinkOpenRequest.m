//
//  JMDeepLinkOpenRequest.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkOpenRequest.h"
#import "JMDeepLink+Additionals.h"
#import "JMDeepLinkObserver.h"
#import "JMDeepLinkStatistics.h"
#import "JMDeepLinkHelper.h"
#import "JMDeepLinkInfo.h"

@interface JMDeepLinkOpenRequest()

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *vendorId;
@property (nonatomic, copy) NSString *brandName;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *osName;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSNumber *screenWidth;
@property (nonatomic, copy) NSNumber *screenHeight;
@property (nonatomic, copy) NSNumber *screenScale;
@property (nonatomic, copy) NSNumber *batteryLevel;
@property (nonatomic, copy) NSNumber *time;

@end

@implementation JMDeepLinkOpenRequest

- (instancetype)initWithSuccess:(void (^)(id, NSURLSessionDataTask *))success Fail:(void (^)(NSError *, NSURLSessionDataTask *))fail {
    
    self = [super init];
    if (self) {
        self.successCallback = success;
        self.failCallback = fail;
        [self setupModel];
    }
    return self;
}

- (void)setupModel {
    BOOL isRealHardwareId;
    NSString *hardwareIdType;
    NSString *hardwareId = [JMDeepLinkObserver getUniqueHardwareId:&isRealHardwareId isDebug:NO andType:&hardwareIdType];
    if (hardwareId && isRealHardwareId) {
        self.uuid = hardwareId;
    }
    
    NSString *appid = [JMDeepLinkStatistics getInstance].appID;
    if (appid) {
        self.appid = appid;
    }
    
    self.vendorId = [JMDeepLinkObserver getVendorId];
    self.brandName = [JMDeepLinkObserver getBrand];
    self.modelName = [JMDeepLinkObserver getModel];
    self.osName = [JMDeepLinkObserver getOS];
    self.osVersion = [JMDeepLinkObserver getOSVersion];
    self.appVersion = [JMDeepLinkObserver getAppVersion];
    self.screenWidth = [JMDeepLinkObserver getScreenWidth];
    self.screenHeight = [JMDeepLinkObserver getScreenHeight];
    self.screenScale = [JMDeepLinkObserver getScreenScale];
    self.batteryLevel = [JMDeepLinkObserver getBatteryLevel];
    self.time = [JMDeepLinkObserver getTime];
    
}

- (JMDeepLinkRequestMethod)method {

    return JMDeepLinkGetRequest;
}

- (NSString *)baseUrl {
    
    return @"https://mob.jumei.com/v1/";
}

- (NSString *)url {

    return @"deeplink/jumpInfo";
}

- (NSDictionary *)customParameters {
    NSMutableDictionary *dic = [@{} mutableCopy];
    [dic dlSetSafeObject:self.uuid forKey:@"uuid"];
    [dic dlSetSafeObject:self.appid forKey:@"appid"];
    [dic dlSetSafeObject:self.vendorId forKey:@"vendorId"];
    [dic dlSetSafeObject:self.brandName forKey:@"brandName"];
    [dic dlSetSafeObject:self.modelName forKey:@"modelName"];
    [dic dlSetSafeObject:self.osName forKey:@"osName"];
    [dic dlSetSafeObject:self.osVersion forKey:@"osVersion"];
    [dic dlSetSafeObject:self.appVersion forKey:@"appVersion"];
    [dic dlSetSafeObject:self.screenWidth forKey:@"screenWidth"];
    [dic dlSetSafeObject:self.screenHeight forKey:@"screenHeight"];
    [dic dlSetSafeObject:self.screenScale forKey:@"screenScale"];
    [dic dlSetSafeObject:self.batteryLevel forKey:@"batteryLevel"];
    [dic dlSetSafeObject:self.time forKey:@"time"];
    
    return [dic copy];
}

- (void)processWithError:(NSError *)error dataTask:(NSURLSessionDataTask *)task {
    if (error) {
        if (self.failCallback) {
            self.failCallback(error, task);
            return;
        }
    }
}

- (void)processWithResponse:(JMDeepLinkResponse *)response dataTask:(NSURLSessionDataTask *)task {

    NSString *jumpUrl = [JMDeepLinkStatistics getInstance].jumpUrl;
    if (![NSString isNilOrNSNullOrEmptyOrWhitespace:jumpUrl]) {
        [JMDeepLinkStatistics getInstance].jumpUrl = nil;
        return;
    }
    
    [self buildCookiesWithTask:task];

    NSDictionary *dic = response.data[@"data"];
    
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        
        NSString *url = [dic objectForKey:[JMDeepLinkStatistics getInstance].jumpUrlKey];
        
        NSDictionary *userData = [self getParamsDicFromUrl:url];
        
        [JMDeepLinkStatistics getInstance].userData = userData;
    } else {
        
        [JMDeepLinkStatistics getInstance].userData = nil;
    }
    
    if (self.successCallback) {
        self.successCallback(dic, task);
    }
    
}

- (NSDictionary *)getParamsDicFromUrl:(NSString *)url {
    
    if (!url) {
        return [@{} copy];
    }
    
    NSMutableDictionary *dic = [@{} mutableCopy];
    
    NSString *jumeimaillStr = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([NSString isNilOrNSNullOrEmptyOrWhitespace:jumeimaillStr]) {
        return [dic copy];
    }
    
    [dic dlSetSafeObject:jumeimaillStr forKey:[JMDeepLinkStatistics getInstance].jumpUrlKey];
    
    return [dic copy];
}

@end
