//
//  JMDeepLinkRequestQueue.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMDeepLinkBaseRequest.h"

@interface JMDeepLinkRequestQueue : NSObject

+ (JMDeepLinkRequestQueue *)getInstance;

- (JMDeepLinkBaseRequest *)peek;

- (JMDeepLinkBaseRequest *)peekAt:(NSUInteger)index;

- (void)enquque:(JMDeepLinkBaseRequest *)request;

- (JMDeepLinkBaseRequest *)dequeue;

- (void)remove:(JMDeepLinkBaseRequest *)request;

- (void)clearQueue;

@end
