//
//  JMDeepLinkStatistics.h
//  JuMei
//
//  Created by bojiaz on 16/9/18.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMDeepLinkStatistics : NSObject

@property (nonatomic, copy) NSArray *deeplinkHosts;

@property (nonatomic, copy) NSString *appID;

@property (nonatomic, strong) NSDictionary *userData;

@property (nonatomic, strong) NSString *jumpUrl;

@property (nonatomic, strong) NSDictionary *dyParams;

@property (nonatomic, strong) NSDictionary *dyCookies;

@property (nonatomic, copy) NSString *jumpUrlKey;

@property (nonatomic, copy) NSString *defaultPageUrl;

@property (nonatomic, copy) NSString *goToSafariLabel;

+ (JMDeepLinkStatistics *)getInstance;

@end
