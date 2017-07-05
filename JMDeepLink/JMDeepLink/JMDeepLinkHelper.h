//
//  JMDeepLinkHelper.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMDeepLinkHelper : NSObject

+ (NSDictionary *)decodeJsonDataToDictionary:(NSData *)jsonData;

+ (NSString *)encodeDictionaryToQueryString:(NSDictionary *)dictionary;

+ (NSData *)encodeDictionaryToJsonData:(NSDictionary *)dictionary;

+ (NSString *)getStringFromUrl:(NSString*)url needle:(NSString *)needle;

+ (BOOL)isDeepLinkJumpStr:(NSString *)str;

@end
