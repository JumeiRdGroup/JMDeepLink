//
//  JMDeepLinkObserver.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkObserver.h"
#include <sys/utsname.h>
#import <UIKit/UIKit.h>

@implementation JMDeepLinkObserver

+ (NSString *)getUniqueHardwareId:(BOOL *)isReal isDebug:(BOOL)debug andType:(NSString **)type {
    NSString *uid = nil;
    *isReal = YES;
    
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass && !debug) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        uid = [uuid UUIDString];
        // limit ad tracking is enabled. iOS 10+
        if ([uid isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            uid = nil;
        }
        *type = @"idfa";
    }
    
    if (!uid && NSClassFromString(@"UIDevice") && !debug) {
        uid = [[UIDevice currentDevice].identifierForVendor UUIDString];
        *type = @"vendor_id";
    }
    
    if (!uid) {
        uid = [[NSUUID UUID] UUIDString];
        *type = @"random";
        *isReal = NO;
    }
    
    return uid;
}

+ (NSString *)getPlatform {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return @"iphone";
    } else {
        return @"ipad";
    }
}

+ (NSString *)getClientVersion {

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppID {

    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)readAppsecret {

    return @"3368aa9d";
}

+ (NSString *)getVendorId {
    NSString *vendorId = nil;
    
    if (NSClassFromString(@"UIDevice")) {
        vendorId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return vendorId;
}

+ (NSString *)getBrand {
    return @"Apple";
}

+ (NSString *)getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)getOS {
    return @"iOS";
}

+ (NSString *)getOSVersion {
    UIDevice *device = [UIDevice currentDevice];
    return [device systemVersion];
}

+ (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSNumber *)getScreenWidth {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat width = mainScreen.bounds.size.width;
    return [NSNumber numberWithInteger:(NSInteger)width];
}

+ (NSNumber *)getScreenHeight {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat height = mainScreen.bounds.size.height;
    return [NSNumber numberWithInteger:(NSInteger)height];
}

+ (NSNumber *)getScreenScale {
    UIScreen *mainScreen = [UIScreen mainScreen];
    float scaleFactor = mainScreen.scale;
    return [NSNumber numberWithFloat:scaleFactor];
}

+ (NSNumber *)getBatteryLevel {
    CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
    return [NSNumber numberWithFloat:batteryLevel];
}

+ (NSNumber *)getTime {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSNumber numberWithLong:interval];
}


@end
