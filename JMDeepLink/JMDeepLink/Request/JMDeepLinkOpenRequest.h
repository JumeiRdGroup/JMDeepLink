//
//  JMDeepLinkOpenRequest.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkBaseRequest.h"
#import "JMDeepLinkBlocks.h"

@interface JMDeepLinkOpenRequest : JMDeepLinkBaseRequest

- (instancetype)initWithSuccess:(void (^)(id response, NSURLSessionDataTask *dataTask))success Fail:(void (^)(NSError *error, NSURLSessionDataTask *dataTask))fail;

@end
