//
//  JMDeepLinkHelper.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkHelper.h"
#import "JMDeepLinkInfo.h"
#import "JMDeepLinkStatistics.h"

@interface JMDeepLinkHelper()

@end

@implementation JMDeepLinkHelper

+ (NSString *)urlEncodedString:(NSString *)string {
    NSMutableCharacterSet *charSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [charSet removeCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:charSet];
}

+ (NSString *)iso8601StringFromDate:(NSDate *)date {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // POSIX to avoid weird issues
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)encodeDictionaryToQueryString:(NSDictionary *)dictionary {
    NSMutableString *queryString = [[NSMutableString alloc] initWithString:@""];
    
    for (NSString *key in [dictionary allKeys]) {
        // No empty keys, please.
        if (key.length) {
            id obj = dictionary[key];
            NSString *value;
            
            if ([obj isKindOfClass:[NSString class]]) {
                value = [JMDeepLinkHelper urlEncodedString:obj];
            }
            else if ([obj isKindOfClass:[NSURL class]]) {
                value = [JMDeepLinkHelper urlEncodedString:[obj absoluteString]];
            }
            else if ([obj isKindOfClass:[NSDate class]]) {
                value = [JMDeepLinkHelper iso8601StringFromDate:obj];
            }
            else if ([obj isKindOfClass:[NSNumber class]]) {
                value = [obj stringValue];
            }
            else {
                // If this type is not a known type, don't attempt to encode it.
                NSLog(@"Cannot encode value %@, type is in not list of accepted types", obj);
                continue;
            }
            
            [queryString appendFormat:@"%@=%@&", [JMDeepLinkHelper urlEncodedString:key], value];
        }
    }
    
    // Delete last character (either trailing & or ? if no params present)
    [queryString deleteCharactersInRange:NSMakeRange(queryString.length - 1, 1)];
    
    return queryString;
}

+ (NSString *)sanitizedStringFromString:(NSString *)dirtyString {
    NSString *cleanString = [[[[dirtyString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
                               stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]
                              stringByReplacingOccurrencesOfString:@"’" withString:@"'"]
                             stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    
    return cleanString;
}

+ (NSData *)encodeDictionaryToJsonData:(NSDictionary *)dictionary {
    NSString *jsonString = [JMDeepLinkHelper encodeDictionaryToJsonString:dictionary];
    NSUInteger length = [jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    return [NSData dataWithBytes:[jsonString UTF8String] length:length];
}

+ (NSString *)encodeDictionaryToJsonString:(NSDictionary *)dictionary {
    NSMutableString *encodedDictionary = [[NSMutableString alloc] initWithString:@"{"];
    for (NSString *key in dictionary) {
        NSString *value = nil;
        BOOL string = YES;
        
        id obj = dictionary[key];
        if ([obj isKindOfClass:[NSString class]]) {
            value = [JMDeepLinkHelper sanitizedStringFromString:obj];
        }
        else if ([obj isKindOfClass:[NSURL class]]) {
            value = [obj absoluteString];
        }
        else if ([obj isKindOfClass:[NSDate class]]) {
            value = [JMDeepLinkHelper iso8601StringFromDate:obj];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            value = [JMDeepLinkHelper encodeArrayToJsonString:obj];
            string = NO;
        }
        else if ([obj isKindOfClass:[NSDictionary class]]) {
            value = [JMDeepLinkHelper encodeDictionaryToJsonString:obj];
            string = NO;
        }
        else if ([obj isKindOfClass:[NSNumber class]]) {
            value = [obj stringValue];
            string = NO;
        }
        else if ([obj isKindOfClass:[NSNull class]]) {
            value = @"null";
            string = NO;
        }
        else {
            // If this type is not a known type, don't attempt to encode it.
            NSLog(@"Cannot encode value for key %@, type is in list of accepted types", key);
            continue;
        }
        
        [encodedDictionary appendFormat:@"\"%@\":", [JMDeepLinkHelper sanitizedStringFromString:key]];
        
        // If this is a "string" object, wrap it in quotes
        if (string) {
            [encodedDictionary appendFormat:@"\"%@\",", value];
        }
        // Otherwise, just add the raw value after the colon
        else {
            [encodedDictionary appendFormat:@"%@,", value];
        }
    }
    
    if (encodedDictionary.length > 1) {
        [encodedDictionary deleteCharactersInRange:NSMakeRange([encodedDictionary length] - 1, 1)];
    }
    
    [encodedDictionary appendString:@"}"];
    
    return encodedDictionary;
}

+ (NSString *)encodeArrayToJsonString:(NSArray *)array {
    // Empty array
    if (![array count]) {
        return @"[]";
    }
    
    NSMutableString *encodedArray = [[NSMutableString alloc] initWithString:@"["];
    for (id obj in array) {
        NSString *value = nil;
        BOOL string = YES;
        
        if ([obj isKindOfClass:[NSString class]]) {
            value = [JMDeepLinkHelper sanitizedStringFromString:obj];
        }
        else if ([obj isKindOfClass:[NSURL class]]) {
            value = [obj absoluteString];
        }
        else if ([obj isKindOfClass:[NSDate class]]) {
            value = [JMDeepLinkHelper iso8601StringFromDate:obj];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            value = [JMDeepLinkHelper encodeArrayToJsonString:obj];
            string = NO;
        }
        else if ([obj isKindOfClass:[NSDictionary class]]) {
            value = [JMDeepLinkHelper encodeDictionaryToJsonString:obj];
            string = NO;
        }
        else if ([obj isKindOfClass:[NSNumber class]]) {
            value = [obj stringValue];
            string = NO;
        }
        else if ([obj isKindOfClass:[NSNull class]]) {
            value = @"null";
            string = NO;
        }
        else {
            // If this type is not a known type, don't attempt to encode it.
            NSLog(@"Cannot encode value %@, type is not in list of accepted types", obj);
            continue;
        }
        
        // If this is a "string" object, wrap it in quotes
        if (string) {
            [encodedArray appendFormat:@"\"%@\",", value];
        }
        // Otherwise, just add the raw value after the colon
        else {
            [encodedArray appendFormat:@"%@,", value];
        }
    }
    
    // Delete the trailing comma
    [encodedArray deleteCharactersInRange:NSMakeRange([encodedArray length] - 1, 1)];
    [encodedArray appendString:@"]"];
    
    return encodedArray;
}

+ (NSDictionary *)decodeJsonDataToDictionary:(NSData *)jsonData {

    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    if (!jsonDic) {
        return @{};
    }
    
    return jsonDic;
}

+ (NSString *)getStringFromUrl:(NSString*)url needle:(NSString *)needle {
    
    NSString *lowerUrl_ = [url lowercaseString];
    NSString *lowerNeedle_ = [needle lowercaseString];
    
    NSString * str = nil;
    NSRange start = [lowerUrl_ rangeOfString:lowerNeedle_];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = (end.location == NSNotFound)? [url substringFromIndex:offset]: [url substringWithRange:NSMakeRange(offset, end.location)];
        
        str = str.stringByRemovingPercentEncoding;
    }
    
    if (str==nil) {
        str=@"";
    }
    return str;
}

+ (BOOL)isDeepLinkJumpStr:(NSString *)str {
    
    NSString *universalLinkDomains = JMDeepLinkDomain;
    NSString *universalLinkPubDomains = JMDeepLinkPubDomain;
    
    if ([str containsString:universalLinkDomains]) {
        return YES;
    }
    
    if ([str containsString:universalLinkPubDomains]) {
        return YES;
    }
    
    NSArray *hosts = [JMDeepLinkStatistics getInstance].deeplinkHosts;
    if (hosts && [hosts isKindOfClass:[NSArray class]]) {
        for (NSString *oneHost in hosts) {
            if (![oneHost isKindOfClass:[NSString class]]) {
                continue;
            }
            if ([str containsString:oneHost]) {
                return YES;
            }
        }
    }
    
    NSString *linkRegex = @"(http|https)://newjump[0-9]\\.jumei\\.com.*?";
    NSPredicate *linkTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",linkRegex];
    if ([linkTest evaluateWithObject:str]) {
        return YES;
    }
    
    return NO;
}

@end
