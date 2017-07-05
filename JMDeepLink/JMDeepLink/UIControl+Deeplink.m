//
//  UIControl+Deeplink.m
//  JuMei
//
//  Created by bojiaz on 2017/4/18.
//  Copyright © 2017年 Jumei Inc. All rights reserved.
//

#import "UIControl+Deeplink.h"
#import <objc/runtime.h>
#import "JMDeepLinkStatistics.h"

@implementation UIControl(Deeplink)

+ (void)deeplinkMethodExchange {

    method_exchangeImplementations(class_getInstanceMethod(self, @selector(sendAction:to:forEvent:)),
                                   class_getInstanceMethod(self, @selector(directSendAction:to:forEvent:)));
}

- (void)directSendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event {

    NSLog(@"DeepLink Hook : action:%s, target:%@ forEvent:%@",sel_getName(action),target,event);
    //右上角为UIStatusBarBreadcrumbItemView 右上角为UIStatusBarOpenInSafariItemView
    if ([target isKindOfClass:NSClassFromString(@"UIStatusBarOpenInSafariItemView")]) {
        NSString *string = [target valueForKey:@"destinationText"];
        if ([string isEqualToString:[JMDeepLinkStatistics getInstance].goToSafariLabel]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[JMDeepLinkStatistics getInstance].defaultPageUrl]];
        }
        return;
    }
    
    [self directSendAction:action to:target forEvent:event];
}


@end
