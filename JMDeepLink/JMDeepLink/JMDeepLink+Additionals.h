//
//  JMDeepLink+Additionals.h
//  JuMei
//
//  Created by bojiaz on 16/9/14.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary(JMDeepLink)

- (void)dlSetSafeObject:(id)object forKey:(id<NSCopying>)key;

@end


@interface NSString(JMDeepLink)

+ (instancetype)dlNilToEmptyStringWithString:(NSString *)string;

+ (BOOL)isNilOrNSNull:(NSString *)str;

+ (BOOL)isEmptyOrWhitespace:(NSString *)str;

+ (BOOL)isNilOrNSNullOrEmptyOrWhitespace:(NSString *)str;

@end
