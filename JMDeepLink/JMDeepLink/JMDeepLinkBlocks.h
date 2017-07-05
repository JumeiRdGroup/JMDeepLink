//
//  JMDeepLinkBlocks.h
//  JuMei
//
//  Created by bojiaz on 16/9/19.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#ifndef JMDeepLinkBlocks_h
#define JMDeepLinkBlocks_h

@class JMDeepLinkResponse;

typedef void (^SuccessCallback)(JMDeepLinkResponse *response, NSURLSessionDataTask *dataTask);

typedef void (^FailCallback)(NSError *error, NSURLSessionDataTask *dataTask);

#endif /* JMDeepLinkBlocks_h */
