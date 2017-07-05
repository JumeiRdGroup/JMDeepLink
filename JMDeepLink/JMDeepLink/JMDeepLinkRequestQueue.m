//
//  JMDeepLinkRequestQueue.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkRequestQueue.h"

@interface JMDeepLinkRequestQueue()

@property (nonatomic, strong) NSMutableArray *queue;

@end

@implementation JMDeepLinkRequestQueue

+ (JMDeepLinkRequestQueue *)getInstance {
    static JMDeepLinkRequestQueue *requestQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestQueue = [[JMDeepLinkRequestQueue alloc] init];
    });
    
    return requestQueue;
}

- (instancetype)init {

    self = [super init];
    if (self) {
        self.queue = [@[] mutableCopy];
    }
    return self;
}

- (void)enquque:(JMDeepLinkBaseRequest *)request {

    @synchronized (self.queue) {
        if (request) {
            [self.queue addObject:request];
        }
    }
}

- (JMDeepLinkBaseRequest *)dequeue {
    JMDeepLinkBaseRequest *request = nil;
    
    @synchronized (self.queue) {
        if ([self.queue count] > 0) {
            request = [self.queue objectAtIndex:([self.queue count] - 1)];
            [self.queue removeObjectAtIndex:([self.queue count] - 1)];
        }
    }
    return request;
}

- (JMDeepLinkBaseRequest *)peek {
 
    return [self peekAt:([self.queue count] - 1)];
}

- (JMDeepLinkBaseRequest *)peekAt:(NSUInteger)index {
    
    if (index >= [self.queue count]) {
        return nil;
    }
    
    JMDeepLinkBaseRequest *request = nil;
    request = [self.queue objectAtIndex:index];
    return request;
}

- (void)remove:(JMDeepLinkBaseRequest *)request {
    if (!request) {
        return;
    }
    @synchronized (self.queue) {
        [self.queue removeObject:request];
    }
}

- (void)clearQueue {
    @synchronized (self.queue) {
        [self.queue removeAllObjects];
    }
}

@end
