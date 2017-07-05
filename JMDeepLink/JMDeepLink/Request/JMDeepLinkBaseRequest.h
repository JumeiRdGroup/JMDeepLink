//
//  JMDeepLinkBaseRequest.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMDeepLinkResponse.h"

typedef NS_ENUM(NSUInteger, JMDeepLinkRequestMethod) {
    JMDeepLinkGetRequest = 0,
    JMDeepLinkPostRequest
};

@interface JMDeepLinkBaseRequest : NSObject

//Request Method Get Or Post
@property (nonatomic, assign) JMDeepLinkRequestMethod method;

//Base Url
@property (nonatomic, copy) NSString *baseUrl;

//Sub Url
@property (nonatomic, copy) NSString *url;

//Request Parameters
@property (nonatomic, strong) NSDictionary *params;

//Cookie
@property (nonatomic, copy) NSString *cookie;

//Success Block
@property (nonatomic, copy) void (^successCallback)(id response, NSURLSessionDataTask *dataTask);

//Fail Block
@property (nonatomic, copy) void (^failCallback)(NSError *error, NSURLSessionDataTask *dataTask);

- (void)processWithResponse:(JMDeepLinkResponse *)response dataTask:(NSURLSessionDataTask *)task;

- (void)processWithError:(NSError *)error dataTask:(NSURLSessionDataTask *)task;

- (void)buildCookiesWithTask:(NSURLSessionDataTask *)task;

- (NSDictionary *)requestHeaders;

- (NSDictionary *)customParameters;
@end
