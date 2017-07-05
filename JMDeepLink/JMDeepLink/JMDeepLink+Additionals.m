//
//  JMDeepLink+Additionals.m
//  JuMei
//
//  Created by bojiaz on 16/9/14.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLink+Additionals.h"

@implementation NSMutableDictionary(JMDeepLink)

- (void)dlSetSafeObject:(id)object forKey:(id<NSCopying>)key
{
    if(object && key)
    {
        [self setObject:object forKey:key];
    }
}

@end


@implementation NSString(JMDeepLink)

+ (instancetype)dlNilToEmptyStringWithString:(NSString *)string {
    if (string) {
        return string;
    } else {
        return @"";
    }
}

+ (BOOL)isNilOrNSNull:(NSString *)str {
    if (!str) {
        return YES;
    }
    if ([str isEqual:[NSNull null]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmptyOrWhitespace:(NSString *)str {
    
    if ([NSString isNilOrNSNull:str]) {
        return YES;
    }
    
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    return 0 == str.length ||
    ![str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

+ (BOOL)isNilOrNSNullOrEmptyOrWhitespace:(NSString *)str {
    if ([NSString isNilOrNSNull:str]) {
        return YES;
    }
    if ([NSString isEmptyOrWhitespace:str]) {
        return YES;
    }
    return NO;
}


@end
