//
//  JMDeepLinkObserver.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMDeepLinkObserver : NSObject

+ (NSString *)getUniqueHardwareId:(BOOL *)isReal isDebug:(BOOL)debug andType:(NSString **)type;

+ (NSString *)getPlatform;

+ (NSString *)getClientVersion;

+ (NSString *)getAppID;

+ (NSString *)readAppsecret;

+ (NSString *)getVendorId;

+ (NSString *)getBrand;

+ (NSString *)getModel;

+ (NSString *)getOS;

+ (NSString *)getOSVersion;

+ (NSString *)getAppVersion;

+ (NSNumber *)getScreenWidth;

+ (NSNumber *)getScreenHeight;

+ (NSNumber *)getScreenScale;

+ (NSNumber *)getBatteryLevel;

+ (NSNumber *)getTime;

@end
