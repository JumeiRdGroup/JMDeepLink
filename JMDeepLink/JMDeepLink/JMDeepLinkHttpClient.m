//
//  JMDeepLinkHttpClient.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkHttpClient.h"
#import "JMDeepLinkHelper.h"
#import "JMDeepLink+Additionals.h"
#import "JMDeepLinkObserver.h"
#import "JMDeepLinkInfo.h"
#import "JMDeepLinkRequestQueue.h"
#import "JMDeepLinkBlocks.h"

NSString * const HttpMethodString[] = {
    [JMDeepLinkGetRequest] = @"GET",
    [JMDeepLinkPostRequest] = @"POST"
};

@interface JMDeepLinkHttpClient()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSSet *MethodsEncodingParamsInURL;

@property (nonatomic, strong) dispatch_semaphore_t queueSemaphore;


@end

@implementation JMDeepLinkHttpClient

+ (JMDeepLinkHttpClient *)getInstance {
    static JMDeepLinkHttpClient *httpClient;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpClient = [[JMDeepLinkHttpClient alloc] init];
        
        httpClient.MethodsEncodingParamsInURL = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
        
        httpClient.queueSemaphore = dispatch_semaphore_create(1);
    });
    
    return httpClient;
}

- (void)processRequest {
    
    dispatch_semaphore_wait(self.queueSemaphore, DISPATCH_TIME_FOREVER);
    
    JMDeepLinkBaseRequest *request = [[JMDeepLinkRequestQueue getInstance] peek];
    
    dispatch_semaphore_signal(self.queueSemaphore);
    
    if (request) {
        
        [[JMDeepLinkHttpClient getInstance] sendRequst:request success:^(JMDeepLinkResponse *response, NSURLSessionDataTask *task) {
            
            [[JMDeepLinkRequestQueue getInstance] dequeue];
            [self processRequest];
            [request processWithResponse:response dataTask:task];
        } fail:^(NSError *error, NSURLSessionDataTask *dataTask) {
            
            [[JMDeepLinkRequestQueue getInstance] remove:request];
            [request processWithError:error dataTask:dataTask];
        }];
    }
    
}

- (NSURLRequest *)prepareRequest:(JMDeepLinkBaseRequest *)request error:(NSError **)error {
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] init];
    
    NSURL *baseUrl = [NSURL URLWithString:request.baseUrl];
    NSURL *url = [NSURL URLWithString:request.url relativeToURL:baseUrl];
    
    //Base Info
    [mutableRequest setURL:url];
    [mutableRequest setHTTPMethod:HttpMethodString[request.method]];
    
    //custom HttpHeaderField
    NSDictionary *requestHeaders = [request requestHeaders];
    if (requestHeaders.count > 0) {
        [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [mutableRequest setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //Content Data
    NSDictionary *preparedParams = request.params;
    
    NSString *query = nil;
    if (preparedParams) {
        query = [JMDeepLinkHelper encodeDictionaryToQueryString:preparedParams];
    }
    
    //[mutableRequest setTimeoutInterval:5];
    
    if ([self.MethodsEncodingParamsInURL containsObject:[[mutableRequest HTTPMethod] uppercaseString]]) {
        if (query) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
    } else {
        if (!query) {
            query = @"";
        }
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        NSUInteger length = [query lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithBytes:[query UTF8String] length:length];
        [mutableRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)length] forHTTPHeaderField:@"Content-Length"];
        [mutableRequest setHTTPBody:data];
    }
    
    return [mutableRequest copy];
}

- (void)sendRequst:(JMDeepLinkBaseRequest *)request success:(SuccessCallback)success fail:(FailCallback)fail {
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        return;
    }
    
    NSError *prepareError = nil;
    NSURLRequest *urlRequest = [self prepareRequest:request error:&prepareError];
    if (prepareError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            fail ? fail(prepareError, nil) : nil;
        });
        return;
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    __block NSURLSessionDataTask *task = nil;
    task = [session dataTaskWithRequest:urlRequest.copy completionHandler:^void(NSData *data, NSURLResponse *response, NSError *error){
        JMDeepLinkResponse *serverResponse = [self processServerResponse:response data:data error:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                success ? success(serverResponse, task) : nil;
            } else {
                fail ? fail(error, task) : nil;
            }
        });
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}



- (JMDeepLinkResponse *)processServerResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    JMDeepLinkResponse *serverResponse = [[JMDeepLinkResponse alloc] init];
    
    if (error) {
        return nil;
    }
    
    serverResponse.statusCode = @([(NSHTTPURLResponse *)response statusCode]);
    serverResponse.data = [JMDeepLinkHelper decodeJsonDataToDictionary:data];
    
    return serverResponse;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,cre);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
