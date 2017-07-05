//
//  JMDeepLinkMatchHelper.m
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkMatchHelper.h"
#import "JMDeepLinkObserver.h"
#import "JMDeepLinkStatistics.h"
#import <SafariServices/SFSafariViewController.h>
#import "JMDeepLinkInfo.h"
#import "JMDeepLink+Additionals.h"
#import "JMDeepLinkHelper.h"


@interface JMDeepLinkMatchHelper()<SFSafariViewControllerDelegate>

@property (strong, nonatomic) UIWindow *secondWindow;
@property (nonatomic, copy) void (^callBlock)(void);

@end

@implementation JMDeepLinkMatchHelper

+ (JMDeepLinkMatchHelper *)getInstance {
    static JMDeepLinkMatchHelper *matchHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        matchHelper = [[JMDeepLinkMatchHelper alloc] init];
    });
    return matchHelper;
}

- (void)createMatchWithCallBlock:(void (^)(void))callBlock {

    self.callBlock = callBlock;
    [self presentSafariViewController];
}

- (void)presentSafariViewController {
    
    NSURL *baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",JMDeepLinkDomain]];
    NSURL *url = [NSURL URLWithString:@"/Deeplink/setJumpInfo" relativeToURL:baseUrl];
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    
    BOOL isRealHardwareId;
    NSString *hardwareIdType;
    NSString *hardwareId = [JMDeepLinkObserver getUniqueHardwareId:&isRealHardwareId isDebug:NO andType:&hardwareIdType];
    if (hardwareId && isRealHardwareId) {
        [mutDic dlSetSafeObject:hardwareId forKey:@"uuid"];
    }
    
    NSString *appID = [JMDeepLinkStatistics getInstance].appID;
    if (appID) {
        [mutDic dlSetSafeObject:appID forKey:@"appid"];
    }
    
    NSString *query = [JMDeepLinkHelper encodeDictionaryToQueryString:mutDic];
    if (query) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:url.query ? @"&%@" : @"?%@", query]];
    }
    
    Class SFSafariViewControllerClass = NSClassFromString(@"SFSafariViewController");
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    
    if (!SFSafariViewControllerClass) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        SFSafariViewController * safController = [[SFSafariViewControllerClass alloc] initWithURL:url];
        if (safController) {
            safController.delegate = self;
            self.secondWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.secondWindow.rootViewController = safController;
            self.secondWindow.windowLevel = UIWindowLevelNormal - 100;
            [self.secondWindow setHidden:NO];
            UIWindow *keyWindow = [[UIApplicationClass sharedApplication] keyWindow];
            [self.secondWindow makeKeyWindow];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [keyWindow makeKeyWindow];
                [self.secondWindow removeFromSuperview];
                self.secondWindow = nil;
            });
        }
    });
}

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {

    if (self.callBlock) {
        self.callBlock();
    }
}

@end
