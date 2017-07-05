//
//  JMDeepLinkHttpClient.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMDeepLinkBaseRequest.h"
#import "JMDeepLinkResponse.h"
#import "JMDeepLinkInfo.h"

@interface JMDeepLinkHttpClient : NSObject

+ (JMDeepLinkHttpClient *)getInstance;

- (void)processRequest;

@end
